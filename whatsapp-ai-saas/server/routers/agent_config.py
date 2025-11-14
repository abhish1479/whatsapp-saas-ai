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
    if not config: 
       return StandardResponse(success=False,data=config, message="Agent configuration data not found for user {tenant_id}. Please create a configuration first.")

    if isinstance(config.preferred_languages, str):
        clean = config.preferred_languages.replace("{", "").replace("}", "")
        config.preferred_languages = [lang.strip() for lang in clean.split(",") if lang.strip()]


    # If found, return successfully
    return StandardResponse(success=False,data=config, message="Agent configuration retrieved successfully.")

@router.put(
    "/update_agent_configuration",
    response_model=APIResponse[AgentConfigResponse],
    summary="Update/Create Agent Configuration (Upsert)",
    description="Updates existing configuration or creates a new one if none is found for the given tenant."
)
def update_agent_configuration(
    payload: AgentConfigPayload,
    db: Session = Depends(get_db)
):
    """
    Updates an existing configuration using only provided fields, 
    or creates a new configuration if none exists.
    """
    
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

    # 1. Prepare data: Only include fields present in the request for UPDATE 
    # exclude={'tenant_id'} ensures we don't try to change the FK, although it's included in exclude_unset=True logic.
    update_data = payload.model_dump(exclude_unset=True, exclude={'tenant_id'})
    
    # 2. Check for existing configuration
    config = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).first()
    
    # 3. Handle update or create (upsert-like logic)
    if config:
        # UPDATE: Apply only the provided fields from the payload (update_data already excludes tenant_id)
        for key, value in update_data.items():
            setattr(config, key, value)
        
        db.commit()
        db.refresh(config)
        message = "Agent configuration updated successfully."
    else:
        # CREATE: Use the complete payload (including defaults for missing optional fields)
        try:
            create_data = payload.model_dump()
            
            # Use the SQLAlchemy model instance creation
            new_config = AgentConfiguration(**create_data) 
            
            db.add(new_config)
            db.commit()
            db.refresh(new_config)
            config = new_config
            message = "New agent configuration created successfully."
        except Exception as e:
            db.rollback()
            logger.error(f"Failed to create new AgentConfiguration for tenant {tenant_id}: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to create agent configuration (check integrity): {e}"
            )
        
    if isinstance(config.preferred_languages, str):
         clean = config.preferred_languages.replace("{", "").replace("}", "")
         config.preferred_languages = [lang.strip() for lang in clean.split(",") if lang.strip()]

    return APIResponse(data=config, message=message)