from pydantic import BaseModel, Field
from typing import List, Optional

# ✅ Request validation for POST
class BusinessTypeRequest(BaseModel):
    tenant_id: int = Field(..., gt=0, description="Tenant ID")
    business_type: str = Field(..., min_length=3, max_length=50)
    description: Optional[str] = Field(None, max_length=500)
    custom_business_type: Optional[str] = Field(None, max_length=100)
    business_category: Optional[str] = Field(None, max_length=100)


class Recipient(BaseModel):
    to: str
    name: str = "Sir/Madam"  # optional with default

class TemplateSendRequest(BaseModel):
    tenant_id: int
    recipients: List[Recipient]