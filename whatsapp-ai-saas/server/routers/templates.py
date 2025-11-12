
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from database import SessionLocal
from deps import get_db
from models import Template
from data_models.template_models import TemplateCreate, TemplateUpdate, TemplateResponse, APIResponse , TemplatesListAPIResponse
from sqlalchemy.orm import Session
from sqlalchemy import func
from utils.enums import TemplateStatusEnum
from models import Tenant


router = APIRouter(prefix="/templates", tags=["Templates"])

def build_response(success: bool, data=None, message: str = "", error=None):
    return APIResponse(success=success, data=data, message=message, error=error)

# --- Endpoints ---
@router.post("/create", response_model=APIResponse)
def create_template(template_in: TemplateCreate, db: Session = Depends(get_db)):
    # Optional: validate tenant exists
    tenant_exists = db.query(func.count()).select_from(Tenant).filter(Tenant.id == template_in.tenant_id).scalar()
    if not tenant_exists:
        return build_response(
            success=False,
            message="Validation failed",
            error={
                "code": "VALIDATION_ERROR",
                "details": ["Tenant not found"]
            }
        )
    template = db.query(Template).filter(
        Template.tenant_id == template_in.tenant_id,
        Template.name == template_in.name).first()
    if template:
        return build_response(
            success=False,
            message="Template with the same name already exists for this tenant",
            error={
                "code": "DUPLICATE_TEMPLATE",
                "details": ["A template with this name already exists"]
            }
        )

    try:
        template = Template(**template_in.model_dump())
        db.add(template)
        db.commit()
        db.refresh(template)

        response_data = TemplateResponse(
            id=template.id,
            tenant_id=template.tenant_id,
            language=template.language,
            category=template.category,
            name=template.name,
            body=template.body,
            status=template.status,
            type=template.type,
            created_at=template.created_at,
            updated_at=template.updated_at,
        )
        return build_response(
            success=True,
            data=response_data,
            message="Template created successfully"
        )
    except Exception as e:
        db.rollback()
        return build_response(
            success=False,
            message="Failed to create template",
            error={"code": "INTERNAL_ERROR", "details": [str(e)]}
        )

@router.get("/get", response_model=APIResponse)
def get_template(template_id: int, db: Session = Depends(get_db)):
    template = db.query(Template).filter(Template.id == template_id).first()
    if not template:
        return build_response(
            success=False,
            message="Template not found",
            error={"code": "NOT_FOUND", "details": ["Template does not exist"]}
        )

    response_data = TemplateResponse(
        id=template.id,
        tenant_id=template.tenant_id,
        language=template.language,
        category=template.category,
        name=template.name,
        body=template.body,
        status=template.status,
        type=template.type,
        created_at=template.created_at,
        updated_at=template.updated_at

    )
    return build_response(
        success=True,
        data=response_data,
        message="Template retrieved successfully"
    )

@router.put("/update", response_model=APIResponse)
def update_template(
    template_id: int,
    template_update: TemplateUpdate,
    db: Session = Depends(get_db)
):
    template = db.query(Template).filter(Template.id == template_id).first()
    if not template:
        return build_response(
            success=False,
            message="Template not found",
            error={"code": "NOT_FOUND", "details": ["Template does not exist"]}
        )

    update_data = template_update.model_dump(exclude_unset=True)
    if not update_data:
        return build_response(
            success=False,
            message="Validation failed",
            error={"code": "VALIDATION_ERROR", "details": ["No update data provided"]}
        )

    for field, value in update_data.items():
        setattr(template, field, value)

    try:
        db.commit()
        db.refresh(template)
        response_data = TemplateResponse(
            id=template.id,
            tenant_id=template.tenant_id,
            language=template.language,
            category=template.category,
            name=template.name,
            body=template.body,
            status=template.status,
            type=template.type,
            created_at=template.created_at,
            updated_at=template.updated_at
        )
        return build_response(
            success=True,
            data=response_data,
            message="Template updated successfully"
        )
    except Exception as e:
        db.rollback()
        return build_response(
            success=False,
            message="Failed to update template",
            error={"code": "UPDATE_ERROR", "details": [str(e)]}
        )

@router.delete("/delete", response_model=APIResponse)
def delete_template(template_id: int, db: Session = Depends(get_db)):
    template = db.query(Template).filter(Template.id == template_id).first()
    if not template:
        return build_response(
            success=False,
            message="Template not found",
            error={"code": "NOT_FOUND", "details": ["Template does not exist"]}
        )

    if template.status == TemplateStatusEnum.ACTIVATED:
        return build_response(
            success=False,
            message="Cannot delete an activated template",
            error={
                "code": "DELETE_RESTRICTED",
                "details": ["Template is in 'Activated' status and cannot be deleted"]
            }
        )

    try:
        db.delete(template)
        db.commit()
        return build_response(
            success=True,
            message="Template deleted successfully"
        )
    except Exception as e:
        db.rollback()
        return build_response(
            success=False,
            message="Failed to delete template",
            error={"code": "DELETE_ERROR", "details": [str(e)]}
        )
    
@router.get("/get_templates_list", response_model=TemplatesListAPIResponse)
def get_templates_by_tenant(
    tenant_id: int,
    db: Session = Depends(get_db)
):
    
    templates = db.query(Template).filter(Template.tenant_id == tenant_id).all()
    response_data = [
        TemplateResponse(
            id=template.id,
            tenant_id=template.tenant_id,
            language=template.language,
            category=template.category,
            name=template.name,
            body=template.body,
            status=template.status,
            type=template.type,
            created_at=template.created_at,
            updated_at=template.updated_at,
        )
        for template in templates
    ]

    return TemplatesListAPIResponse(
        success=True,
        data=response_data,
        message="Templates retrieved successfully"
    )