from fastapi import APIRouter, Depends, File, UploadFile, Form, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
import shutil
import os

# --- PLACEHOLDER IMPORTS (Adjust these based on your project structure) ---
# Assuming these exist in your project:
# from server.deps import get_db, get_current_tenant_id
# from server.models import AgentConfiguration
# from server.utils.media import save_file # Custom file utility
# from settings import settings # Assuming you have a project settings file for media directory
from server.data_models.schemas import AgentConfigResponse # Import new schema

# --- MOCK PLACEHOLDERS FOR CANVAS EXECUTION ---
class MockDB:
    def query(self, *args): return self
    def filter(self, *args): return self
    def first(self): return None
    def add(self, *args): pass
    def commit(self): pass
    def refresh(self, *args): pass
    
def get_db(): return MockDB()
def get_current_tenant_id(): return 1 # Mock tenant ID
class AgentConfiguration: 
    def __init__(self, **kwargs): self.__dict__.update(kwargs)
    def __setattr__(self, name, value): self.__dict__[name] = value

# Mock response schema
class AgentConfigResponse(BaseModel):
    id: int
    tenant_id: int
    agent_name: str
    agent_image: Optional[str] = None
    agent_persona: Optional[str] = None
    greeting_message: Optional[str] = None
    preferred_languages: str
    conversation_tone: str
    class Config:
        orm_mode = True

# Mock file utility to save file locally and return URL
async def save_file(uploaded_file: UploadFile, folder: str):
    upload_dir = "/tmp/media" # Placeholder directory
    os.makedirs(upload_dir, exist_ok=True)
    file_location = os.path.join(upload_dir, uploaded_file.filename)
    
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(uploaded_file.file, buffer)
        
    return f"http://api.humainity.ai/media/{folder}/{uploaded_file.filename}"
# ---------------------------------------------


router = APIRouter(prefix="/agent-config", tags=["AI Agent Configuration"])

# --- GET ENDPOINT ---
@router.get(
    "/", 
    response_model=AgentConfigResponse,
    summary="Get Agent Configuration for Tenant"
)
async def get_agent_configuration(
    tenant_id: int = Depends(get_current_tenant_id),
    db: Session = Depends(get_db),
):
    """
    Fetches the currently saved agent configuration for the authenticated tenant.
    """
    config = db.query(AgentConfiguration).filter(
        AgentConfiguration.tenant_id == tenant_id
    ).first()

    if not config:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent configuration not found for this tenant.",
        )
    
    return config

# --- POST ENDPOINT (Voice Model Removed) ---
@router.post("/save")
async def save_agent_configuration(
    # Fields from the form data
    agent_name: str = Form(...),
    agent_persona: str = Form(None),
    greeting_message: str = Form(None),
    preferred_languages: str = Form(...), # Comma-separated string
    conversation_tone: str = Form(...),
    # voice_model: str = Form(...), # <-- REMOVED
    # Optional file upload
    agent_image: Optional[UploadFile] = File(None),
    # Dependencies
    tenant_id: int = Depends(get_current_tenant_id),
    db: Session = Depends(get_db),
):
    """Handles saving the agent configuration and optionally uploads an avatar image."""
    
    image_url = None
    if agent_image and agent_image.filename:
        # Utility function to save the file and return its public URL
        image_url = await save_file(agent_image, folder=f"tenants/{tenant_id}/avatars")
        
    config = db.query(AgentConfiguration).filter(
        AgentConfiguration.tenant_id == tenant_id
    ).first()

    if config:
        # Update existing config
        config.agent_name = agent_name
        config.agent_persona = agent_persona
        config.greeting_message = greeting_message
        config.preferred_languages = preferred_languages
        config.conversation_tone = conversation_tone
        # config.voice_model = voice_model # <-- REMOVED
        if image_url: # Only update image if a new one was uploaded
            config.agent_image = image_url
    else:
        # Create new config
        config = AgentConfiguration(
            tenant_id=tenant_id,
            agent_name=agent_name,
            agent_persona=agent_persona,
            greeting_message=greeting_message,
            preferred_languages=preferred_languages,
            conversation_tone=conversation_tone,
            # voice_model=voice_model, # <-- REMOVED
            agent_image=image_url,
        )
        db.add(config)

    db.commit()
    db.refresh(config)
    
    return {
        "message": "Agent configuration saved successfully", 
        "config_id": config.id, 
        "image_url": config.agent_image
    }