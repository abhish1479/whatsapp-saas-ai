from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from utils.enums import TemplateStatusEnum, TemplateTypeEnum

class TemplateBase(BaseModel):
    name: str
    language: Optional[str] = "en"
    category: Optional[str] = "MARKETING"
    body: str
    media_link: Optional[str] = None
    media_type: Optional[str] = "text"
    status: TemplateStatusEnum = TemplateStatusEnum.DRAFT
    type: TemplateTypeEnum

class TemplateCreate(TemplateBase):
    tenant_id: int

class TemplateUpdate(BaseModel):
    name: Optional[str] = None
    language: Optional[str] = None
    category: Optional[str] = None
    body: Optional[str] = None
    media_link: Optional[str] = None
    media_type: Optional[str] = None
    status: Optional[TemplateStatusEnum] = None
    type: Optional[TemplateTypeEnum] = None

class TemplateResponse(TemplateBase,BaseModel):
    id: int
    tenant_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True  # Pydantic v2 ORM mode

class APIResponse(BaseModel):
    success: bool
    data: Optional[TemplateResponse] = None
    message: str
    error: Optional[dict] = None

class TemplatesListAPIResponse(BaseModel):
    success: bool
    data: List[TemplateResponse]
    message: str
    error: Optional[dict] = None