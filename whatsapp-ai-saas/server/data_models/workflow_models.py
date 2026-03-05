from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime

class WorkflowBase(BaseModel):
    name: str
    json: Dict[str, Any] = Field(validation_alias="json", serialization_alias="json_body")

class WorkflowCreate(WorkflowBase):
    pass

class WorkflowUpdate(BaseModel):
    name: Optional[str] = None
    json: Optional[Dict[str, Any]] = Field(validation_alias="json", serialization_alias="json_body")
    is_default: Optional[bool] = None

class WorkflowResponse(WorkflowBase):
    id: int
    tenant_id: int
    is_default: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
