from fastapi import APIRouter, Depends, File, UploadFile, Form, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
import json 
from deps import get_db
from models import AgentConfiguration, Tenant 
from data_models.agent_config_reponse import AgentConfigResponse, AgentConfigPayload, APIResponse 
from utils.media import save_image
from utils.responses import StandardResponse  
from data_models.agent_config_reponse import (
    AgentConfigResponse, 
    AgentConfigPayload, 
    APIResponse, 
    APIError, 
    ErrorDetail
)   
import logging

logger = logging.getLogger(__name__)


# Create a new router. This is the "route file" you wanted.
router = APIRouter(prefix="/agent-config", tags=["agent-config"]
)

# --- GET ENDPOINT (Updated to use APIResponse) ---
@router.get(
    "/get_agent_configuration", 
    response_model=APIResponse[AgentConfigResponse], # Wrap in APIResponse
    summary="Get Agent Configuration for Tenant"
)
async def get_agent_configuration(
    tenant_id: int, 
    db: Session = Depends(get_db),
):
    config = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).first()
    
    # REQUIRED CHANGE 1: If config not found, return structured 404 error (No auto-creation)
    if not config: return StandardResponse(
        success=False,
        data=None,
        message=f"Agent configuration not found for this tenant.",
    )

    if isinstance(config.preferred_languages, str):
        clean = config.preferred_languages.replace("{", "").replace("}", "")
        config.preferred_languages = [lang.strip() for lang in clean.split(",") if lang.strip()]


    # If found, return successfully
    return StandardResponse(success=True,data=config, message="Agent configuration retrieved successfully.")

@router.put(
    "/update_agent_configuration",
    response_model=APIResponse[AgentConfigResponse],
    summary="Update/Create Agent Configuration (Upsert)",
    description="Updates existing configuration or creates a new one if none is found for the given tenant."
)
def update_agent_configuration(
    # payload: AgentConfigPayload,
    payload: str = Form(...),
    agent_image: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    """
    Updates an existing configuration using only provided fields, 
    or creates a new configuration if none exists.
    """
    try:
        payload_dict = json.loads(payload)
        payload = AgentConfigPayload(**payload_dict)
    except Exception as e:
        return APIResponse(
            success=False,
            data=None,
            message="Invalid payload format",
            error=APIError(
                code="INVALID_PAYLOAD",
                details=[ErrorDetail(field="payload", message=str(e))]
            )
        )

    tenant_id = payload.tenant_id
    
    # Check if the Tenant exists (ensures FK integrity check is passed if not handled by auth middleware)
    tenant_check = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    if not tenant_check:
        error = APIError(
            code="TENANT_NOT_FOUND",
            details=[ErrorDetail(field="tenant_id", message=f"User/Tenant with ID {tenant_id} does not exist.")]
        )
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error.model_dump_json(exclude_none=True)
        )

    config = db.query(AgentConfiguration).filter(
        AgentConfiguration.tenant_id == tenant_id
    ).first()

    update_data = payload.model_dump(exclude_unset=True, exclude={"tenant_id"})

    if agent_image:
        saved_path = save_image(agent_image, folder="agent_images")
        update_data["agent_image"] = saved_path


    if config:
        for key, value in update_data.items():
            setattr(config, key, value)
        db.commit()
        db.refresh(config)
        message = "Agent configuration updated successfully."
    else:
        new_data = payload.model_dump()
        if agent_image:
            new_data["agent_image"] = saved_path

        config = AgentConfiguration(**new_data)
        db.add(config)
        db.commit()
        db.refresh(config)
        message = "New agent configuration created successfully."

    if isinstance(config.preferred_languages, str):
        clean = config.preferred_languages.replace("{", "").replace("}", "")
        config.preferred_languages = [lang.strip() for lang in clean.split(",") if lang.strip()]

    return APIResponse(
        success=True,
        data=config,
        message=message
    )