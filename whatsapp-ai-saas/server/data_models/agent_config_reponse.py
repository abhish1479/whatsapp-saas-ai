from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

# Base fields shared by Create, Update, and Response
class AgentConfigurationBase(BaseModel):
    agent_name: str = Field(..., max_length=100)
    agent_image: Optional[str] = Field(None, max_length=1000)
    agent_persona: Optional[str] = None
    greeting_message: Optional[str] = Field(None, max_length=500)
    voice_model: Optional[str] = Field(None, max_length=100)
    voice_accent: Optional[str] = Field(None, max_length=100)
    preferred_languages: str = Field(default="en", max_length=100)
    conversation_tone: str = Field(default="professional", max_length=50)

# Request Model for Creating
class AgentConfigurationCreate(AgentConfigurationBase):
    tenant_id: int = Field(..., description="The ID of the tenant this agent belongs to")

# Request Model for Updating (All fields optional)
class AgentConfigurationUpdate(BaseModel):
    id: int
    agent_name: Optional[str] = Field(None, max_length=100)
    agent_image: Optional[str] = Field(None, max_length=1000)
    agent_persona: Optional[str] = None
    greeting_message: Optional[str] = Field(None, max_length=500)
    voice_model: Optional[str] = Field(None, max_length=100)
    voice_accent: Optional[str] = Field(None, max_length=100)
    preferred_languages: Optional[str] = Field(None, max_length=100)
    conversation_tone: Optional[str] = Field(None, max_length=50)

# Response Model (Output)
class AgentConfigurationResponse(AgentConfigurationBase):
    id: int
    tenant_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True