# server/routers/rag.py
from typing import List
from fastapi import APIRouter
from fastapi.params import Depends
from requests import Session
from services.rag import rag
from deps import get_db
from models import BusinessCatalog

router = APIRouter(prefix="/rag", tags=["rag"])

@router.post("/add")
async def add_doc(tenant_id: int, doc_id: str, text: str, source_url: str | None = None, version: str | None = None, language: str | None = "en"):
    await rag.add_documents(tenant_id, [{
        "id": doc_id,
        "text": text,
        "source_url": source_url,
        "version": version,
        "language": language,
    }])
    return {"ok": True}

@router.get("/search")
async def search(tenant_id: int, q: str, n: int = 6):
    return {"results": await rag.search(tenant_id, q, k=n)}

@router.get("/query")
async def query_raw(tenant_id: int, q: str, n: int = 6):
    return await rag.query(tenant_id, q, n=n)

@router.get("/answer")
async def answer(tenant_id: int, q: str):
    return await rag.answer(tenant_id, q)


@router.post("/add_catalog")
async def add_catalog(
    catalog_ids: List[int],
    db: Session = Depends(get_db),
):
    """
    Fetch catalog items by ID and add them to RAG vector store.
    """
    if not catalog_ids:
        return {"ok": True, "message": "No catalog IDs provided"}

    # Fetch catalog items from DB
    catalogs = db.query(BusinessCatalog).filter(
        BusinessCatalog.id.in_(catalog_ids)
    ).all()

    if not catalogs:
        return {"ok": True, "message": "No catalogs found for provided IDs"}

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

    return {
        "ok": True,
        "added_count": len(documents),
        "tenant_id": tenant_id,
        "catalog_ids": catalog_ids
    }