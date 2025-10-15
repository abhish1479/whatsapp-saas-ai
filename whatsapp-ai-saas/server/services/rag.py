# services/rag.py
from __future__ import annotations
from typing import List, Dict, Any, Optional
import os
import uuid
import logging

from sqlalchemy import func
from database import SessionLocal
from sqlalchemy.orm import Session
from models import BusinessCatalog, Tenant

logger = logging.getLogger(__name__)


class RAGService:
    """
    Thin abstraction over a vector DB (default: Chroma).
    Uses the new Chroma PersistentClient (no legacy Settings / chroma_db_impl).
    """

    def __init__(self):
        self.provider = os.getenv("RAG_PROVIDER", "chroma").lower()  # chroma|pinecone|weaviate
        self._client = None  # lazy init
        self._path = os.getenv("CHROMA_PATH", "/data/chroma")  # used by Chroma
        if self.provider != "chroma":
            logger.warning("RAG_PROVIDER=%s currently not implemented; defaulting to Chroma", self.provider)

    # ---------- internal helpers ----------

    @property
    def client(self):
        """Lazy-initialize the underlying DB client."""
        if self._client is not None:
            return self._client

        if self.provider == "chroma" or True:
            try:
                # New API — no legacy Settings/chroma_db_impl
                from chromadb import PersistentClient  # type: ignore
            except Exception as e:
                raise RuntimeError(
                    "Chroma is not installed or failed to import. "
                    "Add `chromadb` to server/requirements.txt or pin a compatible version."
                ) from e

            os.makedirs(self._path, exist_ok=True)
            self._client = PersistentClient(path=self._path)
            logger.info("Initialized Chroma PersistentClient at %s", self._path)
            return self._client

        # In the future: other providers here
        raise NotImplementedError(f"RAG provider '{self.provider}' is not implemented yet.")

    def _ns(self, tenant_id: str) -> str:
        return f"tenant-{tenant_id}"

    def _coll_name(self, tenant_id: str) -> str:
        return self._ns(tenant_id)

    def _get_collection(self, tenant_id: str):
        """Create or fetch per-tenant collection."""
        name = self._coll_name(tenant_id)
        return self.client.get_or_create_collection(name=name)

    # ---------- public API ----------

    async def add_documents(self, tenant_id: str, docs: List[Dict[str, Any]]):
        """
        docs = [{id?, text, source_url?, version?, language?}]
        """
        if not docs:
            return

        col = self._get_collection(tenant_id)
        ids = [str(d.get("id") or uuid.uuid4()) for d in docs]
        texts = [d["text"] for d in docs]
        metadatas = [
            {
                "source_url": d.get("source_url"),
                "version": d.get("version") or "",
                "language": d.get("language") or "",
            }
            for d in docs
        ]
        # Chroma client is sync; it's fine to call from async here
        col.add(ids=ids, documents=texts, metadatas=metadatas)

    async def delete_namespace(self, tenant_id: str) -> None:
        """
        Hard-delete the tenant collection (GDPR/DPDP). Irreversible.
        """
        name = self._coll_name(tenant_id)
        try:
            self.client.delete_collection(name=name)
        except Exception as e:
            # If not found, swallow; otherwise re-raise
            msg = str(e).lower()
            if "not found" in msg:
                return
            raise

    async def query(self, tenant_id: str, query: str, n: int = 6) -> Dict[str, Any]:
        """
        Returns a Chroma-style result dict:
          { 'ids': [...], 'documents': [[...]], 'metadatas': [[...]], 'distances': [[...]] }
        If empty, returns { 'documents': [] }.
        """
        col = self._get_collection(tenant_id)
        try:
            if getattr(col, "count")() == 0:
                return {"documents": []}
        except Exception:
            # Some client versions may not have count() — just attempt query.
            pass

        res = col.query(query_texts=[query], n_results=n)
        # Normalize to a predictable shape
        if not res or not res.get("documents"):
            return {"documents": []}
        return res

    async def search(self, tenant_id: str, query: str, k: int = 6) -> List[Dict[str, Any]]:
        """
        Convenience: returns a simplified list of {text, metadata, score} for top-k.
        """
        raw = await self.query(tenant_id, query, n=k)
        docs = raw.get("documents") or []
        metas = raw.get("metadatas") or []
        dists = raw.get("distances") or []
        out: List[Dict[str, Any]] = []
        if not docs:
            return out

        # Chroma returns lists-of-lists (per query); we issued a single query, so index 0.
        docs0 = docs[0] if docs and isinstance(docs[0], list) else docs
        metas0 = metas[0] if metas and isinstance(metas[0], list) else metas
        dists0 = dists[0] if dists and isinstance(dists[0], list) else dists

        for i, text in enumerate(docs0):
            meta = metas0[i] if i < len(metas0) else {}
            score = dists0[i] if i < len(dists0) else None
            out.append({"text": text, "metadata": meta, "score": score})
        return out

    async def answer(self, tenant_id: str, query: str) -> Dict[str, Any]:
        """
        Extremely simple “answer” — stitches top document text.
        In production, pass retrieved docs to your LLM with guardrails.
        """
        res = await self.query(tenant_id, query, n=6)
        docs = res.get("documents") or []
        metas = res.get("metadatas") or []

        if not docs:
            return {
                "answer": "I don't have info yet; connecting you to the business owner.",
                "sources": [],
            }

        # Merge the top hit
        top_docs = docs[0] if isinstance(docs[0], list) else docs
        top_metas = metas[0] if metas and isinstance(metas[0], list) else metas
        merged = " ".join([d for d in top_docs if isinstance(d, str)])[:500]
        return {"answer": merged, "sources": top_metas}
    

# Singleton instance for imports like: from services.rag import rag
rag = RAGService()

async def add_catalog_to_rag(tenant_id: int):
    db: Session = SessionLocal()
    try:
        print("Adding catalog to RAG for tenant:", tenant_id)
        if not tenant_id:
            return {"ok": False, "message": "tenant ID not provided"}

        catalogs = db.query(BusinessCatalog).filter(
            BusinessCatalog.tenant_id == tenant_id).all()
        print(f"Found {len(catalogs)} catalogs for tenant {tenant_id}")
        if not catalogs:
            return {"ok": False, "message": "No catalogs found"}

        # Prepare documents for RAG
        documents = []
        for catalog in catalogs:
            txt = (
                    f"Name: {catalog.name}\n"
                    f"Description: {catalog.description or 'Not available'}\n"
                    f"Category: {catalog.category or 'Uncategorized'}\n"
                    f"Type: {catalog.item_type or 'Unknown'}\n"
                    f"Price: {catalog.price if catalog.price is not None else 'N/A'} {catalog.currency or 'USD'}\n"
                    f"Discount: {catalog.discount if catalog.discount is not None else '0%'}\n"
                    f"Source URL: {catalog.source_url or 'N/A'}\n"
                    f"Image URL: {catalog.image_url or 'N/A'}\n"
                    f"Created: {catalog.created_at.strftime('%Y-%m-%d %H:%M') if catalog.created_at else 'Unknown'}\n"
                    f"Updated: {catalog.updated_at.strftime('%Y-%m-%d %H:%M') if catalog.updated_at else 'Unknown'}"
                )
            
            documents.append({
                "id": str(catalog.id),  # RAG systems usually expect string IDs
                "text": txt,
                "source_url": catalog.source_url,
                "version": "1.0",  # You can make this dynamic if needed
                "language": "en",  # Adjust based on tenant or catalog metadata
            })

        # Add to RAG system
        tenant_id = catalogs[0].tenant_id  # Assuming all have same tenant_id
        await rag.add_documents(tenant_id, documents)
        print(f"Added {len(documents)} documents to RAG for tenant {tenant_id}")
        tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
        tenant.rag_enabled = True
        tenant.rag_updated_at = func.now()
        db.add(tenant)
        db.commit()
        return {
            "ok": True,
            "added_count": len(documents),
            "tenant_id": tenant_id,
        }

    except Exception as e:
        logger.exception("Error in add_catalog_to_rag for tenant %s: %s", tenant_id, str(e))
        db.rollback()
        return {"ok": False, "message": str(e)}
    finally:
        db.close() 
