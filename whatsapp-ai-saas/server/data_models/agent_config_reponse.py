from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class AgentConfigResponse(BaseModel):
    id: int
    tenant_id: int
    agent_name: str
    agent_image: Optional[str] = None
    agent_persona: Optional[str] = None
    greeting_message: Optional[str] = None
    # voice_model: Optional[str] = None # <-- REMOVED
    preferred_languages: str # Will be "en,es,fr"
    conversation_tone: str

    class Config:
        orm_mode = True # To convert from SQLAlchemy model

# ... (rest of your schemas.py) ...