from dataclasses import Field
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel

class ReviewResponse(BaseModel):
    tenant_id: int
    onboarding_process: str

    has_business_profile: bool
    has_business_type: Optional[bool] = False
    has_items: Optional[bool] = False
    has_web_ingest: Optional[bool] = False
    has_workflow: Optional[bool] = False
    has_kyc: Optional[bool] = False
    has_payment: Optional[bool] = False
    has_agent_configuration: Optional[bool] = False
    has_profile_activate: Optional[bool] = False

    item_count: int

    business_name: Optional[str] = None
    business_whatsapp: Optional[str] = None     # CHANGED
    personal_number: Optional[str] = None       # NEW
    language: Optional[str] = None
    business_type: Optional[str] = None
    business_description: Optional[str] = None
    custom_business_type: Optional[str] = None
    business_category: Optional[str] = None

    items: List[dict] = []
    web_ingest: Optional[dict] = None
    workflow: Optional[dict] = None
    kyc: Optional[dict] = None
    payment: Optional[dict] = None
    agent_configuration: Optional[dict] = None
    tenant: Optional[dict] = None

class AgentConfigurationBase(BaseModel):
    tenant_id: int
    agent_name: str 
    agent_image: str 
    status: str
    preferred_languages: str
    conversation_tone: str 
    incoming_voice_message_enabled: bool = True
    outgoing_voice_message_enabled: bool = True
    incoming_media_message_enabled: bool = True
    outgoing_media_message_enabled: bool = True
    image_analyzer_enabled: bool = False


class AgentConfigurationResponse(AgentConfigurationBase):
    id: int
    tenant_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True  # For SQLAlchemy ORM compatibility