from typing import List, Optional
from openai import BaseModel

class ReviewResponse(BaseModel):
    tenant_id: str
    onboarding_process: str
    has_business_profile: bool
    has_business_type: Optional[bool]=False
    has_items: Optional[bool]=False
    has_web_ingest: Optional[bool]=False
    has_workflow: Optional[bool]=False
    has_payment: Optional[bool]=False
    item_count: int
    has_profile_activate: Optional[bool]=False
    business_name: Optional[str] = None
    owner_phone: Optional[str] = None
    language: Optional[str] = None
    items: List[dict] = []
    web_ingest: Optional[dict] = None
    workflow: Optional[dict] = None
    payment: Optional[dict] = None