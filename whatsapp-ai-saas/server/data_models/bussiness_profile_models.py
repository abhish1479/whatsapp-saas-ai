from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime

# --- Business Profile Schemas ---

# Base schema for data shared between input and output
class BusinessProfileBase(BaseModel):
    tenant_id: int
    business_name: str
    business_whatsapp: str
    personal_number: Optional[str] = None
    language: str = "en"
    business_type: Optional[str] = None
    description: Optional[str] = None
    is_active: bool = False

# Schema for creating a new profile (POST request body)
class BusinessProfileCreate(BusinessProfileBase):
    # Tenant ID is essential for creation
    pass

# Schema for updating an existing profile (PUT request body)
class BusinessProfileUpdate(BaseModel):
    # All fields optional for update
    id:int
    business_name: Optional[str] = None
    business_whatsapp: Optional[str] = None
    personal_number: Optional[str] = None
    language: Optional[str] = None
    business_type: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None

# Schema for response (GET request response model)
class BusinessProfileOut(BusinessProfileBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    created_at: datetime
    updated_at: datetime
    
# NOTE: You should ensure this content is merged into your existing
# server/data_models/schemas.py if it already exists.