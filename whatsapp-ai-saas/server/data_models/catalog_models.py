from decimal import Decimal
from typing import List, Optional

from pydantic import BaseModel, Field


class CatalogOut(BaseModel):
    id: int
    item_type: Optional[str] = None
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
    tenant_id: int
    item_type: Optional[str] = None # e.g., "product" or "service"
    name: str
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[Decimal] = None
    discount: Optional[Decimal] = None
    # currency is optional in create; default from settings
    source_url: Optional[str] = None
    image_url: Optional[str] = None

class CatalogUpdate(BaseModel):
    item_id: int
    item_type: Optional[str] = None
    name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[Decimal] = None
    discount: Optional[Decimal] = None
    currency: Optional[str] = None
    source_url: Optional[str] = None
    image_url: Optional[str] = None

class BulkUpload(BaseModel):
    items: List[CatalogCreate]