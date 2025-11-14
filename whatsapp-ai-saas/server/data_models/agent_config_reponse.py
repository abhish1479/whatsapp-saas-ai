from pydantic import BaseModel, Field, ConfigDict
from typing import Generic, TypeVar, Optional, List, Any
from datetime import datetime

# Define the TypeVar for generics
T = TypeVar('T')

# =========================================================
# Error Response Models for structured errors
# =========================================================

class ErrorDetail(BaseModel):
    """Details about a specific validation or system error."""
    field: Optional[str] = Field(None, description="The field name that caused the error (if validation related).")
    message: str = Field(..., description="The error message.")

class APIError(BaseModel):
    """The structured error object."""
    code: str = Field(..., description="A unique code for the error type (e.g., 'NOT_FOUND', 'VALIDATION_ERROR').")
    details: List[ErrorDetail] = Field(..., description="A list of specific error details.")
    
# =========================================================
# APIResponse
# =========================================================
class APIResponse(BaseModel, Generic[T]):
    """
    A generic response model for API endpoints.
    Ensures a consistent structure for success responses.
    """
    status: str = Field(default="success", description="Status of the request (e.g., 'success', 'error').")
    message: Optional[str] = Field(default=None, description="Optional human-readable message.")
    data: Optional[T] = Field(default=None, description="The primary data payload of the response.")
    error: Optional[APIError] = Field(None, description="Structured error details for status='error'.")


class AgentConfigPayload(BaseModel):
    """
    Data model for creating or updating Agent Configuration (Request Body).
    """
    
    # 1. REQUIRED FIELD (No default)
    agent_name: str 
    tenant_id: int 
    # 2. OPTIONAL FIELDS (Explicit None/Field(None))
    agent_image: Optional[str] = Field(None, description="URL of the agent's profile image.")
    agent_persona: Optional[str] = Field(None, description="The detailed role description for the LLM.")
    greeting_message: Optional[str] = Field(None, description="The initial message sent to a customer.")
    voice_model: Optional[str] = Field(None, description="The voice model ID for TTS.")
    # 3. FIELDS WITH DEFAULT VALUES or default_factory (Must follow the above)
    conversation_tone: str = Field("professional", description="The tone of the conversation (e.g., 'friendly', 'formal').")
    preferred_languages: List[str] = Field(default_factory=lambda: ["en"], description="List of languages the agent supports (e.g., ['en', 'hi']).")


class AgentConfigResponse(BaseModel):
    # 1. REQUIRED/DB FIELDS (No default)
    tenant_id: int
    agent_name: str
    created_at: datetime
    updated_at: datetime
    
    # 2. OPTIONAL FIELDS (Explicit None/Field(None))
    agent_image: Optional[str] = Field(None, description="URL of the agent's profile image.")
    agent_persona: Optional[str] = Field(None, description="The detailed role description for the LLM.")
    greeting_message: Optional[str] = Field(None, description="The initial message sent to a customer.")
    voice_model: Optional[str] = Field(None, description="The voice model ID for TTS.")

    # 3. FIELDS WITH DEFAULT VALUES or default_factory
    incoming_voice_message_enabled: bool = True
    outgoing_voice_message_enabled: bool = True
    incoming_media_message_enabled: bool = True
    outgoing_media_message_enabled: bool = True
    image_analyzer_enabled: bool = False
    conversation_tone: str = Field("professional", description="The tone of the conversation (e.g., 'friendly', 'formal').")
    preferred_languages: List[str] = Field(default_factory=lambda: ["en"], description="List of languages the agent supports.")

# Example usage for the router response model:
# APIResponse[AgentConfigResponse]
# APIResponse[List[AgentConfigResponse]]