from __future__ import annotations
from typing import List, Dict, Any, Optional
import os
import uuid

# Placeholder abstraction; wire any vector DB behind this interface.
class RAGService:
    def __init__(self):
        self.provider = os.getenv("RAG_PROVIDER", "chroma")  # chroma|pinecone|weaviate
        # configure clients lazily

    def _ns(self, tenant_id: str) -> str:
        return f"tenant::{tenant_id}"

    async def search(self, tenant_id: str, query: str, k: int = 6) -> List[Dict[str, Any]]:
        """Return top-k docs with scores and metadata."""
        # TODO: hybrid search + rerank
        return []

    async def delete_namespace(self, tenant_id: str) -> None:
        # Danger: irreversible. Use for GDPR/DPDP deletes.
        return
    
    def _coll_name(self, tenant_id: str):
        return f"tenant::{tenant_id}"

    async def add_documents(self, tenant_id: str, docs: List[Dict]):
        """
        docs = [{id, text, source_url, version, language}]
        """
        coll = self.client.get_or_create_collection(name=self._coll_name(tenant_id))
        ids = [d.get("id") or str(uuid.uuid4()) for d in docs]
        texts = [d["text"] for d in docs]
        metadata = [{"source_url": d.get("source_url"), "version": d.get("version"), "lang": d.get("language")} for d in docs]
        coll.add(ids=ids, documents=texts, metadatas=metadata)

    async def query(self, tenant_id: str, query: str, n: int = 6):
        coll = self.client.get_or_create_collection(name=self._coll_name(tenant_id))
        if coll.count() == 0:
            return []  # empty RAG namespace
        res = coll.query(query_texts=[query], n_results=n)
        return res

    async def answer(self, tenant_id: str, query: str):
        """
        Simple naive answer generator. In real flow, pass retrieved docs to LLM.
        """
        docs = await self.query(tenant_id, query)
        if not docs or not docs.get("documents"):
            return {"answer": "I don't have info yet, connecting you to the business owner.", "sources": []}
        merged = " ".join(docs["documents"][0])
        return {"answer": merged[:500], "sources": docs.get("metadatas", [])}


rag = RAGService()
