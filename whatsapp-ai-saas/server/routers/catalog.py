# server/routers/catalog.py
import io
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse
from sqlalchemy import text
from sqlalchemy.orm import Session
from typing import Optional, List, Any, Dict
from io import BytesIO, StringIO
import csv, os, shutil
from decimal import Decimal, InvalidOperation
from models import BusinessCatalog
from settings import settings
from deps import get_db
from data_models.catalog_models import CatalogOut, CatalogCreate, CatalogUpdate, BulkUpdateIn
from utils.media import save_image      

router = APIRouter(prefix="/catalog", tags=["catalog"])



# ------- Endpoints -------
@router.get("/get_catalog", response_model=List[CatalogOut])
def list_catalog(
    tenant_id: int ,
    q: Optional[str] = None,
    limit: int = 200,
    offset: int = 0,
    db: Session = Depends(get_db),
):
    query = db.query(BusinessCatalog).filter(BusinessCatalog.tenant_id == tenant_id)
    if q:
        like = f"%{q}%"
        query = query.filter(BusinessCatalog.name.ilike(like))
    items = query.order_by(BusinessCatalog.id.desc()).offset(offset).limit(limit).all()
    return items

@router.get("/csv-template")
def csv_template():
    # Only include fields allowed in CSV
    header = ["item_type", "name", "description", "category", "price", "discount", "source_url", "image_url"]
    s = StringIO()
    w = csv.writer(s)
    w.writerow(header)
    # add an example row
    w.writerow(["service","AMC","1 Year","Repair","500","20","https://example.com/spa","https://example.com/img.jpg"])
    buf = BytesIO(s.getvalue().encode("utf-8"))
    return StreamingResponse(
        buf, media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=business_catalog_template.csv"}
    )

@router.post("/add", response_model=CatalogOut)
def create_catalog_item(
    payload: CatalogCreate,
    db: Session = Depends(get_db)
):
    item = BusinessCatalog(
        tenant_id=payload.tenant_id,
        item_type=payload.item_type,
        name=payload.name,
        description=payload.description,
        category=payload.category,
        price=payload.price,
        discount=payload.discount,
        currency=settings.CURRENCY,
        source_url=payload.source_url,
        image_url=payload.image_url,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item

@router.post("/add_with_media", response_model=CatalogOut)
def create_catalog_item_with_image(
    item_type: str = Form(...),
    name: str = Form(...),
    tenant_id: int = Form(...),
    description: Optional[str] = Form(None),
    category: Optional[str] = Form(None),
    price: Optional[str] = Form(None),
    discount: Optional[str] = Form(None),
    source_url: Optional[str] = Form(None),
    image: UploadFile = File(None),
    db: Session = Depends(get_db),
):
    image_url = save_image(image) if image else None
    price_d = Decimal(price) if price not in (None, "", "null") else None
    discount_d = Decimal(discount) if discount not in (None, "", "null") else None
    item = BusinessCatalog(
        tenant_id=tenant_id,
        item_type=item_type,
        name=name,
        description=description,
        category=category,
        price=price_d,
        discount=discount_d,
        currency=settings.CURRENCY,
        source_url=source_url,
        image_url=image_url,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item

@router.put("/update", response_model=CatalogOut)
def update_catalog_item(
    payload: CatalogUpdate,
    db: Session = Depends(get_db)
):
    item = db.query(BusinessCatalog).filter(
        BusinessCatalog.id == payload.item_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    for k, v in payload.dict(exclude_unset=True).items():
        setattr(item, k, v)
    db.commit()
    db.refresh(item)
    return item

@router.delete("/delete")
def delete_catalog_item(
    item_id: int,
    db: Session = Depends(get_db),
):
    item = db.query(BusinessCatalog).filter(
        BusinessCatalog.id == item_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    db.delete(item)
    db.commit()
    return {"ok": True}

@router.post("/bulk-update")
def bulk_update(
    payload: BulkUpdateIn,
    db: Session = Depends(get_db)
):
    if not payload.ids:
        return {"updated": 0}
    q = db.query(BusinessCatalog).filter(
        BusinessCatalog.tenant_id == payload.update.tenant_id,
        BusinessCatalog.id.in_(payload.ids)
    )
    update_data = {k: v for k, v in payload.update.dict(exclude_unset=True).items()}
    updated = 0
    for item in q.all():
        for k, v in update_data.items():
            setattr(item, k, v)
        updated += 1
    db.commit()
    return {"updated": updated}

@router.post("/CSV_upload")
async def import_catalog_file(
    tenant_id: int = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    # --- Validate file type ---
    if not file.filename or not file.filename.lower().endswith('.csv'):
        raise HTTPException(status_code=400, detail="Only CSV files are allowed")

    # --- Read CSV ---
    content = await file.read()
    try:
        s = io.StringIO(content.decode("utf-8", errors="ignore"))
        reader = csv.DictReader(s)
        rows = list(reader)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid CSV file: {e}")

    if not rows:
        raise HTTPException(status_code=400, detail="CSV file is empty")

    # --- Validate all rows before inserting ---
    validated_items = []
    for idx, r in enumerate(rows, start=1):
        # Validate name
        name = (r.get("name") or "").strip()
        if not name:
            raise HTTPException(
                status_code=400,
                detail=f"Row {idx}: 'name' is required and cannot be empty"
            )

        # Validate item_type
        item_type = (r.get("item_type") or "").strip()
        if not item_type:
            raise HTTPException(
                status_code=400,
                detail=f"Row {idx}: 'item_type' is required"
            )
        if not item_type :
            raise HTTPException(
                status_code=400,
                detail=f"Row {idx}: 'item_type' is required"
            )

        # Parse optional fields
        def safe_decimal(val):
            if val in (None, "", "nan", "null", "N/A"):
                return None
            try:
                return Decimal(str(val).strip())
            except (ValueError, InvalidOperation, TypeError):
                return None

        item = BusinessCatalog(
            tenant_id=tenant_id,
            item_type=item_type,
            name=name,
            description=str(r.get("description") or "").strip() or None,
            category=str(r.get("category") or "").strip() or None,
            price=safe_decimal(r.get("price")),
            discount=safe_decimal(r.get("discount")),
            currency=settings.CURRENCY,
            source_url=str(r.get("source_url") or "").strip() or None,
            image_url=str(r.get("image_url") or "").strip() or None,
        )
        validated_items.append(item)

    # --- Bulk insert ---
    for item in validated_items:
        db.add(item)
    db.commit()

    return {"ok": True, "created": len(validated_items)}


@router.post("/image_upload")
def image_upload(
    payload: UploadFile = File(...),

):
    if not payload.filename or not payload.filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
        raise HTTPException(status_code=400, detail="Only image files are allowed")
    image_url = save_image(payload)
    return {"image_url": image_url}