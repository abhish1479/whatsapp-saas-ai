from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

# Assuming your models and dependency functions are imported correctly
from deps import get_db 
from models import BusinessProfile, User 
from data_models.bussiness_profile_models import BusinessProfileOut, BusinessProfileCreate, BusinessProfileUpdate
from utils.enums import Onboarding

router = APIRouter(
    prefix="/business_profile", 
    tags=["Business Profile"],
)


# --- Utility Functions (Service Logic Merged) ---

def get_profile_by_tenant_id(db: Session, tenant_id: int) -> BusinessProfile | None:
    """Fetches the business profile for a given tenant ID."""
    return db.query(BusinessProfile).filter(BusinessProfile.tenant_id == tenant_id).first()


# --- API Endpoints ---

@router.post(
    "/create", 
    response_model=BusinessProfileOut, 
    status_code=status.HTTP_201_CREATED,
    summary="Create Business Profile (Onboarding)"
)
def create_business_profile(
    payload: BusinessProfileCreate,
    db: Session = Depends(get_db),
    # tenant_id: int = Depends(get_current_tenant_id) # Use this if getting tenant_id from JWT
):
    """Creates a new business profile. Ensures only one per tenant exists."""
    
    # 1. Check for existing profile
    existing = get_profile_by_tenant_id(db, payload.tenant_id)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Profile already exists for tenant ID {payload.tenant_id}. Use PUT to update."
        )
    bussiness_profile = db.query(BusinessProfile).filter(BusinessProfile.business_whatsapp == payload.business_whatsapp).first()
    if bussiness_profile:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Profile already exists with business WhatsApp {payload.business_whatsapp}."
        )
    # 2. Create the profile
    profile = BusinessProfile(**payload.model_dump())
    db.add(profile)
    #update user profile status to completed
    user = db.query(User).filter(User.tenant_id == payload.tenant_id).first()
    if user:
        user.onboarding_process = Onboarding.COMPLETED
    db.commit()
    db.refresh(profile)
    return profile


@router.get(
    "/get", 
    response_model=BusinessProfileOut,
    summary="Get Business Profile by Tenant ID"
)
def get_business_profile(
    tenant_id: int, 
    db: Session = Depends(get_db),
    # current_tenant_id: int = Depends(get_current_tenant_id)
):
    """Retrieves the business profile for a specific tenant."""
    
    profile = get_profile_by_tenant_id(db, tenant_id)
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Business Profile not found")
    
    return profile


@router.put(
    "/update", 
    response_model=BusinessProfileOut,
    summary="Update Business Profile by Tenant ID"
)
def update_business_profile(
    updates: BusinessProfileUpdate, 
    db: Session = Depends(get_db),
    # current_tenant_id: int = Depends(get_current_tenant_id)
):
    """Updates an existing business profile. Only fields provided will be changed."""

    profile = db.query(BusinessProfile).filter(BusinessProfile.id == updates.id).first()
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Business Profile not found for update")

    # Update logic
    update_data = updates.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(profile, key, value)
        
    db.commit()
    db.refresh(profile)
    return profile