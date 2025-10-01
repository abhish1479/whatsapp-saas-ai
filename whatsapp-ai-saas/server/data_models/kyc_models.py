# kyc_models.py

from datetime import datetime
from pydantic import BaseModel, Field, validator
from typing import Optional
import re

# --- Regex Patterns ---
AADHAAR_PATTERN = re.compile(r"^\d{12}$")      # 12 digits
PAN_PATTERN = re.compile(r"^[A-Z]{5}\d{4}[A-Z]$")  # ABCDE1234F

class KycBase(BaseModel):
    aadhaar_number: str = Field(..., description="12-digit Indian Aadhaar number")
    pan_number: str = Field(..., description="10-character Indian PAN (e.g., ABCDE1234F)")
    status: str = "pending"
    document_image_url: Optional[str] = None
    rejected_reason: Optional[str] = None

    @validator("aadhaar_number")
    def validate_aadhaar(cls, v):
        if not AADHAAR_PATTERN.match(v):
            raise ValueError("Aadhaar number must be exactly 12 numeric digits")
        return v

    @validator("pan_number")
    def validate_pan(cls, v):
        if not PAN_PATTERN.match(v):
            raise ValueError("PAN must be 10 characters: 5 uppercase letters, 4 digits, 1 uppercase letter (e.g., ABCDE1234F)")
        return v

    @validator("status")
    def validate_status(cls, v):
        if v not in {"pending", "verified", "rejected"}:
            raise ValueError("status must be one of: pending, verified, rejected")
        return v


class KycCreate(KycBase):
    user_id: int
    tenant_id: int


class KycUpdate(BaseModel):
    status: Optional[str] = None
    rejected_reason: Optional[str] = None

    @validator("status", always=True)
    def validate_status(cls, v):
        if v is not None and v not in {"pending", "verified", "rejected"}:
            raise ValueError("status must be one of: pending, verified, rejected")
        return v

class KycDocumentUpdate(BaseModel):
    aadhaar_number: Optional[str] = None
    pan_number: Optional[str] = None
    document_image_url: Optional[str] = None

    @validator("aadhaar_number", always=True)
    def validate_aadhaar(cls, v):
        if v is not None:
            if not AADHAAR_PATTERN.match(v):
                raise ValueError("Aadhaar number must be exactly 12 numeric digits")
        return v

    @validator("pan_number", always=True)
    def validate_pan(cls, v):
        if v is not None:
            if not PAN_PATTERN.match(v):
                raise ValueError("PAN must be 10 characters: 5 uppercase letters, 4 digits, 1 uppercase letter (e.g., ABCDE1234F)")
        return v
    
    @validator("document_image_url", always=True)
    def validate_document_url(cls, v):
        if v is not None:
            # Optional: Basic URL validation (you can use urllib.parse in prod)
            if len(v) > 512:
                raise ValueError("Document image URL cannot exceed 512 characters")
            # Optional: Check for http/https
            if not (v.startswith("http://") or v.startswith("https://")):
                raise ValueError("Document image URL must be a valid HTTP/HTTPS URL")
        return v

    class Config:
        extra = "forbid"  # Prevent any other fields

class KycResponse(KycBase):
    id: int
    user_id: int
    tenant_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    verified_at: Optional[datetime] = None

    class Config:
        from_attributes = True