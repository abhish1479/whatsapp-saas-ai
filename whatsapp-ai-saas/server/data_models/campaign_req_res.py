from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class CampaignActionEnum(str, Enum):
    START = "start"
    PAUSE = "pause"

class CampaignListResponse(BaseModel):
    id: int
    name: str
    channel: str
    status: str
    created_at: datetime
    total_leads: int
    new: int
    sent: int
    failed: int
    success: int
    
    class Config:
        from_attributes = True

class CampaignDetailResponse(CampaignListResponse):
    default_pitch: Optional[str] = None
    template_name: Optional[str] = None
    


class CampaignStatusUpdate(BaseModel):
    action: CampaignActionEnum