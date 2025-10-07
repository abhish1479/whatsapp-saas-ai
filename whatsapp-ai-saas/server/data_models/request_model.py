from pydantic import BaseModel, Field
from typing import Optional

# ✅ Request validation for POST
class BusinessTypeRequest(BaseModel):
    tenant_id: int = Field(..., gt=0, description="Tenant ID")
    business_type: str = Field(..., min_length=3, max_length=50)
    description: Optional[str] = Field(None, max_length=500)
    custom_business_type: Optional[str] = Field(None, max_length=100)
    business_category: Optional[str] = Field(None, max_length=100)