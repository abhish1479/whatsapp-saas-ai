# server/routers/catalog.py
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse
from sqlalchemy.orm import Session
from typing import Optional, List, Any, Dict
from io import BytesIO, StringIO
import csv, os, shutil
from decimal import Decimal
from ..database import get_db
from ..models import BusinessCatalog
from ..settings import settings
from ..deps import get_current_user  # or your tenant dependency
from pydantic import BaseModel, Field

router = APIRouter(prefix="/catalog", tags=["catalog"])

# ------- Schemas -------
class CatalogOut(BaseModel):
    id: int
    item_type: str
    name: str
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[Decimal] = None
    discount: Optional[Decimal] = None
    currency: Optional[str] = None
    source_url: Optional[str] = None
    image_url: Optional[str] = None
    class Config:
        orm_mode = True

class CatalogCreate(BaseModel):
    item_type: str = Field(..., description="product|service|course|package|room|membership|other")
    name: str
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[Decimal] = None
    discount: Optional[Decimal] = None
    # currency is optional in create; default from settings
    source_url: Optional[str] = None
    image_url: Optional[str] = None

class CatalogUpdate(BaseModel):
    item_type: Optional[str] = None
    name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[Decimal] = None
    discount: Optional[Decimal] = None
    currency: Optional[str] = None
    source_url: Optional[str] = None
    image_url: Optional[str] = None

class BulkUpdateIn(BaseModel):
    ids: List[int]
    update: CatalogUpdate

# ------- Helpers -------
def _tenant_id_from_user(user: Any) -> int:
    # Adjust to your auth model; typically user.tenant_id
    tid = getattr(user, "tenant_id", None)
    if tid is None:
        raise HTTPException(status_code=400, detail="No tenant_id on user")
    return tid

def _save_image(file: UploadFile) -> str:
    # save into MEDIA_DIR and return public URL
    filename = file.filename
    dest_path = os.path.join(settings.MEDIA_DIR, filename)
    # avoid overwrite: add suffix if exists
    base, ext = os.path.splitext(filename)
    i = 1
    while os.path.exists(dest_path):
        filename = f"{base}_{i}{ext}"
        dest_path = os.path.join(settings.MEDIA_DIR, filename)
        i += 1
    with open(dest_path, "wb") as f:
        shutil.copyfileobj(file.file, f)
    return f"{settings.BASE_URL}/media/{filename}"

# ------- Endpoints -------
@router.get("", response_model=List[CatalogOut])
def list_catalog(
    q: Optional[str] = None,
    limit: int = 200,
    offset: int = 0,
    db: Session = Depends(get_db),
    user: Any = Depends(get_current_user),
):
    tenant_id = _tenant_id_from_user(user)
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
    w.writerow(["service","Full Body Massage","60 min aromatherapy","Spa Service","120","20","https://example.com/spa","https://example.com/img.jpg"])
    buf = BytesIO(s.getvalue().encode("utf-8"))
    return StreamingResponse(
        buf, media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=business_catalog_template.csv"}
    )

@router.post("", response_model=CatalogOut)
def create_catalog_item(
    payload: CatalogCreate,
    db: Session = Depends(get_db),
    user: Any = Depends(get_current_user),
):
    tenant_id = _tenant_id_from_user(user)
    item = BusinessCatalog(
        tenant_id=tenant_id,
        item_type=payload.item_type,
        name=payload.name,
        description=payload.description,
        category=payload.category,
        price=payload.price,
        discount=payload.discount,
        currency=settings.DEFAULT_CURRENCY,
        source_url=payload.source_url,
        image_url=payload.image_url,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item

@router.post("/with-image", response_model=CatalogOut)
def create_catalog_item_with_image(
    item_type: str = Form(...),
    name: str = Form(...),
    description: Optional[str] = Form(None),
    category: Optional[str] = Form(None),
    price: Optional[str] = Form(None),
    discount: Optional[str] = Form(None),
    source_url: Optional[str] = Form(None),
    image: UploadFile = File(None),
    db: Session = Depends(get_db),
    user: Any = Depends(get_current_user),
):
    tenant_id = _tenant_id_from_user(user)
    image_url = _save_image(image) if image else None
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
        currency=settings.DEFAULT_CURRENCY,
        source_url=source_url,
        image_url=image_url,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item

@router.put("/{item_id}", response_model=CatalogOut)
def update_catalog_item(
    item_id: int,
    payload: CatalogUpdate,
    db: Session = Depends(get_db),
    user: Any = Depends(get_current_user),
):
    tenant_id = _tenant_id_from_user(user)
    item = db.query(BusinessCatalog).filter(
        BusinessCatalog.id == item_id, BusinessCatalog.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    for k, v in payload.dict(exclude_unset=True).items():
        setattr(item, k, v)
    db.commit()
    db.refresh(item)
    return item

@router.delete("/{item_id}")
def delete_catalog_item(
    item_id: int,
    db: Session = Depends(get_db),
    user: Any = Depends(get_current_user),
):
    tenant_id = _tenant_id_from_user(user)
    item = db.query(BusinessCatalog).filter(
        BusinessCatalog.id == item_id, BusinessCatalog.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    db.delete(item)
    db.commit()
    return {"ok": True}

@router.post("/bulk-update")
def bulk_update(
    payload: BulkUpdateIn,
    db: Session = Depends(get_db),
    user: Any = Depends(get_current_user),
):
    tenant_id = _tenant_id_from_user(user)
    if not payload.ids:
        return {"updated": 0}
    q = db.query(BusinessCatalog).filter(
        BusinessCatalog.tenant_id == tenant_id,
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

@router.post("/import")
async def import_catalog_file(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    user: Any = Depends(get_current_user),
):
    """
    Accepts CSV/XLS/XLSX. For CSV, we read directly.
    For Excel, we fallback to pandas if available.
    Required columns: item_type, name, description, category, price, discount, source_url, image_url
    """
    tenant_id = _tenant_id_from_user(user)
    filename = file.filename.lower()
    content = await file.read()

    rows: List[Dict[str, Any]] = []
    if filename.endswith(".csv"):
        s = StringIO(content.decode("utf-8", errors="ignore"))
        reader = csv.DictReader(s)
        rows = list(reader)
    else:
        try:
            import pandas as pd  # requires pandas + openpyxl in requirements
            buf = BytesIO(content)
            df = pd.read_excel(buf)
            rows = df.to_dict(orient="records")
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Unsupported file or pandas error: {e}")

    required = ["item_type","name","description","category","price","discount","source_url","image_url"]
    for r in rows:
        for col in required:
            if col not in r:
                raise HTTPException(status_code=400, detail=f"Missing column: {col}")

    created = 0
    for r in rows:
        price = r.get("price")
        discount = r.get("discount")
        price_d = Decimal(str(price)) if price not in (None, "", "nan") else None
        discount_d = Decimal(str(discount)) if discount not in (None, "", "nan") else None
        item = BusinessCatalog(
            tenant_id=tenant_id,
            item_type=str(r.get("item_type") or "other"),
            name=str(r.get("name") or "").strip(),
            description=r.get("description"),
            category=r.get("category"),
            price=price_d,
            discount=discount_d,
            currency=settings.DEFAULT_CURRENCY,
            source_url=r.get("source_url"),
            image_url=r.get("image_url"),
        )
        if not item.name:
            continue
        db.add(item)
        created += 1
    db.commit()
    return {"created": created}
