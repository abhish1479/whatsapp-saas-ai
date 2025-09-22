# server/routers/rag.py
from fastapi import APIRouter
from services.rag import rag

router = APIRouter(prefix="/rag", tags=["rag"])

@router.post("/add")
async def add_doc(tenant_id: str, doc_id: str, text: str, source_url: str | None = None, version: str | None = None, language: str | None = "en"):
    await rag.add_documents(tenant_id, [{
        "id": doc_id,
        "text": text,
        "source_url": source_url,
        "version": version,
        "language": language,
    }])
    return {"ok": True}

@router.get("/search")
async def search(tenant_id: str, q: str, n: int = 6):
    return {"results": await rag.search(tenant_id, q, k=n)}

@router.get("/query")
async def query_raw(tenant_id: str, q: str, n: int = 6):
    return await rag.query(tenant_id, q, n=n)

@router.get("/answer")
async def answer(tenant_id: str, q: str):
    return await rag.answer(tenant_id, q)
