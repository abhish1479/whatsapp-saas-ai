
from fastapi import APIRouter, Depends, UploadFile, File, Form
from pydantic import BaseModel
from deps import get_current
from services.rag import ingest_text, query_kb

router = APIRouter()

class FAQItem(BaseModel):
    q:str
    a:str

class FAQReq(BaseModel):
    items:list[FAQItem]

@router.post("/faq")
def add_faq(body:FAQReq, ident=Depends(get_current)):
    texts = []
    for it in body.items:
        texts.append(f"Q: {it.q}\nA: {it.a}")
    doc_id = ingest_text(ident['tid'], "\n\n".join(texts), {"type":"faq"})
    return {"doc_id": doc_id}

@router.post("/text")
async def add_text(text:str = Form(...), ident=Depends(get_current)):
    doc_id = ingest_text(ident['tid'], text, {"type":"text"})
    return {"doc_id": doc_id}

class QueryReq(BaseModel):
    q:str

@router.post("/query")
def rag_query(body:QueryReq, ident=Depends(get_current)):
    res = query_kb(ident['tid'], body.q, top_k=4)
    return res
