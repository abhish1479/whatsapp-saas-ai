from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

# Adjust these imports based on your actual file structure
from deps import get_db 
from models import AgentConfiguration, Tenant 
from utils.responses import StandardResponse 
from data_models.agent_config_reponse import (
    AgentConfigurationCreate, 
    AgentConfigurationUpdate, 
    AgentConfigurationResponse
)

router = APIRouter(
    prefix="/agent-config",
    tags=["Agent Configuration"]
)

# 1. CREATE Agent Configuration
@router.post("/create", response_model=StandardResponse[AgentConfigurationResponse])
def create_agent_config(
    config_in: AgentConfigurationCreate, 
    db: Session = Depends(get_db)
):
    # Validate Tenant Exists (to prevent ForeignKey error)
    tenant = db.query(Tenant).filter(Tenant.id == config_in.tenant_id).first()
    if not tenant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"Tenant with ID {config_in.tenant_id} does not exist."
        )

    # Validate Uniqueness (tenant_id + agent_name)
    existing_agent = db.query(AgentConfiguration).filter(
        AgentConfiguration.tenant_id == config_in.tenant_id,
        AgentConfiguration.agent_name == config_in.agent_name
    ).first()
    
    if existing_agent:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="An agent with this name already exists for this tenant."
        )

    # Create new record
    new_config = AgentConfiguration(**config_in.model_dump())
    
    try:
        db.add(new_config)
        db.commit()
        db.refresh(new_config)
        return StandardResponse(
            data=new_config, 
            message="Agent configuration created successfully."
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# 2. GET Agent Configuration by ID
@router.get("/get_agent_config_by_id", response_model=StandardResponse[AgentConfigurationResponse])
def get_agent_config(
    config_id: int, 
    db: Session = Depends(get_db)
):
    config = db.query(AgentConfiguration).filter(AgentConfiguration.id == config_id).first()
    
    if not config:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Agent configuration not found."
        )
    
    return StandardResponse(
        data=config, 
        message="Agent configuration retrieved successfully."
    )


# 3. GET All Configurations for a specific Tenant
@router.get("/get_agent_configs_by_tenant", response_model=StandardResponse[AgentConfigurationResponse])
def get_agent_configs_by_tenant(
    tenant_id: int, 
    db: Session = Depends(get_db)
):
    # configs = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).all()
    
    # return StandardResponse(
    #     data=configs, 
    #     message=f"Found {len(configs)} configuration(s) for tenant {tenant_id}."
    # )
    config = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).first()
    
    if not config:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Agent configuration not found."
        )
    
    return StandardResponse(
        data=config, 
        message="Agent configuration retrieved successfully."
    )


# 4. UPDATE Agent Configuration
@router.put("/update", response_model=StandardResponse[AgentConfigurationResponse])
def update_agent_config(
    config_update: AgentConfigurationUpdate, 
    db: Session = Depends(get_db)
):
    # Fetch existing
    existing_config = db.query(AgentConfiguration).filter(AgentConfiguration.id == config_update.id).first()
    
    if not existing_config:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Agent configuration not found."
        )

    # Check Name Uniqueness if name is being updated
    if config_update.agent_name and config_update.agent_name != existing_config.agent_name:
        duplicate_check = db.query(AgentConfiguration).filter(
            AgentConfiguration.tenant_id == existing_config.tenant_id,
            AgentConfiguration.agent_name == config_update.agent_name
        ).first()
        if duplicate_check:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="An agent with this name already exists for this tenant."
            )

    # Update fields
    update_data = config_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(existing_config, field, value)

    try:
        db.commit()
        db.refresh(existing_config)
        return StandardResponse(
            data=existing_config, 
            message="Agent configuration updated successfully."
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))