from pydantic import BaseModel, Field
from typing import Optional, List, Any
from datetime import datetime

class LeadCreate(BaseModel):
    tenant_id: int
    name: Optional[str] = None
    phone: str
    email: Optional[str] = None
    tags: List[str] = Field(default_factory=list)
    product_service: Optional[str] = None
    pitch: Optional[str] = None
    workflow_id: Optional[int] = None

class LeadUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    tags: Optional[List[str]] = None
    product_service: Optional[str] = None
    pitch: Optional[str] = None
    workflow_id: Optional[int] = None
    status: Optional[str] = None

class LeadOut(BaseModel):
    id: int
    tenant_id: int
    name: Optional[str]
    phone: str
    email: Optional[str]
    tags: List[str]
    product_service: Optional[str]
    pitch: Optional[str]
    workflow_id: Optional[int]
    status: str
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True

class CampaignCreate(BaseModel):
    tenant_id: int
    name: str
    schedule_at: Optional[datetime] = None
    auto_schedule_json: Optional[dict] = None
    audience_filter_json: Optional[dict] = None
    template_id: Optional[int] = None
    default_pitch: Optional[str] = None
    default_workflow_id: Optional[int] = None

class CampaignOut(BaseModel):
    id: int
    tenant_id: int
    name: str
    status: str
    schedule_at: Optional[datetime]
    auto_schedule_json: Optional[dict]
    audience_filter_json: Optional[dict]
    template_id: Optional[int]
    default_pitch: Optional[str]
    default_workflow_id: Optional[int]
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True

class LaunchRequest(BaseModel):
    send_now: bool = True

class RecipientOut(BaseModel):
    id: int
    campaign_id: int
    lead_id: int
    send_status: str
    send_at: Optional[datetime]
    deliver_at: Optional[datetime]
    read_at: Optional[datetime]
    reply_at: Optional[datetime]
    converted_at: Optional[datetime]
    error_code: Optional[str]
    credit_units: int
    meta: dict

    class Config:
        from_attributes = True
