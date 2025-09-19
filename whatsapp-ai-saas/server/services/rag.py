# server/services/rag.py
import os, uuid
from typing import List, Dict
from chromadb import Client
from chromadb.config import Settings

CHROMA_PATH = os.getenv("CHROMA_PATH", "./chroma")

client = Client(Settings(chroma_db_impl="duckdb+parquet", persist_directory=CHROMA_PATH))

class RAGService:
    def __init__(self, client):
        self.client = client

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

rag = RAGService(client)
