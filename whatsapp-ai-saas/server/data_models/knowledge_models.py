from typing import Optional
import uuid
from pydantic import BaseModel, HttpUrl
from datetime import datetime
from utils.enums import SourceTypeEnum, ProcessingStatusEnum # <-- UPDATED import path

# --- Pydantic Schemas ---
# Schemas control the data shape for API requests and responses.

class KnowledgeSourceBase(BaseModel):
    """Base schema with common fields."""
    name: str
    source_type: SourceTypeEnum
    source_uri: Optional[str] = None # <-- UPDATED to be optional
    tenant_id: int 

class UrlUploadRequest(BaseModel):
    """Payload for uploading a new URL."""
    tenant_id: int 
    url: HttpUrl # Use HttpUrl for automatic URL validation
    name: str # Optional: let user name the source

class KnowledgeSourceResponse(KnowledgeSourceBase):
    """Full response model for a KnowledgeSource record."""
    id: int
    processing_status: ProcessingStatusEnum
    summary: Optional[str] = None
    tags: Optional[list[str]] = [] 
    vector_chunk_count: Optional[int] = 0
    created_at: datetime
    updated_at: datetime # <-- ADDED
    last_processed_at: Optional[datetime] = None
    processing_error: Optional[str] = None
    size_bytes: Optional[int] = None # <-- FIX: Changed '=' to ':' and added default

    class Config:
        from_attributes = True # (Formerly orm_mode) Read data from SQLAlchemy models