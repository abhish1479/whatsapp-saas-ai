# routers/kyc.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional
from deps import get_db
from models import Kyc, User, Tenant
from data_models.kyc_models import KycCreate, KycDocumentUpdate, KycUpdate, KycResponse
from datetime import datetime

router = APIRouter(prefix="/kyc", tags=["KYC"])


@router.post("/create_kyc", response_model=KycResponse)
def create_or_update_kyc(
    kyc_data: KycCreate,
    db: Session = Depends(get_db)
):
    # Validate user exists
    user = db.query(User).filter(User.id == kyc_data.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Validate tenant belongs to user (optional security check)
    if user.tenant_id != kyc_data.tenant_id:
        raise HTTPException(status_code=403, detail="User does not belong to this tenant")

    # Check if KYC already exists for this user
    existing_kyc = db.query(Kyc).filter(Kyc.user_id == kyc_data.user_id).first()

    # Check for duplicate Aadhaar or PAN (across all users)
    if db.query(Kyc).filter(Kyc.aadhaar_number == kyc_data.aadhaar_number).first():
        raise HTTPException(status_code=409, detail="Aadhaar number already registered")

    if db.query(Kyc).filter(Kyc.pan_number == kyc_data.pan_number).first():
        raise HTTPException(status_code=409, detail="PAN number already registered")

    if existing_kyc:
        # UPDATE
        for field, value in kyc_data.dict(exclude_unset=True).items():
            setattr(existing_kyc, field, value)
        if kyc_data.status == "verified":
            existing_kyc.verified_at = datetime.utcnow()
        db.commit()
        db.refresh(existing_kyc)
        return existing_kyc

    else:
        # CREATE
        new_kyc = Kyc(**kyc_data.dict())
        if kyc_data.status == "verified":
            new_kyc.verified_at = datetime.utcnow()
        db.add(new_kyc)
        db.commit()
        db.refresh(new_kyc)
        return new_kyc


@router.patch("/update_kyc_status", response_model=KycResponse)
def update_kyc(
    kyc_id: int,
    update_data: KycUpdate,
    db: Session = Depends(get_db)
):
    kyc = db.query(Kyc).filter(Kyc.id == kyc_id).first()
    if not kyc:
        raise HTTPException(status_code=404, detail="KYC record not found")

    # Optional: Ensure user has permission to update (if you have auth)
    # if not is_owner_or_admin(user_id, kyc.user_id): ...

    for field, value in update_data.dict(exclude_unset=True).items():
        setattr(kyc, field, value)

    if update_data.status == "verified":
        kyc.verified_at = datetime.utcnow()
    elif update_data.status == "rejected" and not update_data.rejected_reason:
        raise HTTPException(status_code=400, detail="rejected_reason is required when status is 'rejected'")

    db.commit()
    db.refresh(kyc)
    return kyc


@router.patch("/update_documents", response_model=KycResponse)
def update_kyc_documents(
    kyc_id: int,
    doc_update: KycDocumentUpdate,
    db: Session = Depends(get_db)
):
    kyc = db.query(Kyc).filter(Kyc.id == kyc_id).first()
    if not kyc:
        raise HTTPException(status_code=404, detail="KYC record not found")

    # Only allow update if status is 'pending' or 'rejected'
    if kyc.status not in {"pending", "rejected"}:
        raise HTTPException(
            status_code=403,
            detail="Cannot update Aadhaar or PAN after verification. Contact support."
        )

    # Check if new Aadhaar is already used by another user
    if doc_update.aadhaar_number:
        existing = db.query(Kyc).filter(
            Kyc.aadhaar_number == doc_update.aadhaar_number,
            Kyc.id != kyc_id  # Exclude current record
        ).first()
        if existing:
            raise HTTPException(status_code=409, detail="Aadhaar number already registered by another user")

    # Check if new PAN is already used by another user
    if doc_update.pan_number:
        existing = db.query(Kyc).filter(
            Kyc.pan_number == doc_update.pan_number,
            Kyc.id != kyc_id  # Exclude current record
        ).first()
        if existing:
            raise HTTPException(status_code=409, detail="PAN number already registered by another user")

    # Update fields if provided
    if doc_update.aadhaar_number:
        kyc.aadhaar_number = doc_update.aadhaar_number
    if doc_update.pan_number:
        kyc.pan_number = doc_update.pan_number
    
    if doc_update.document_image_url is not None:  # Allow None to clear the URL
        kyc.document_image_url = doc_update.document_image_url

    # Reset verification status if document changed
    if kyc.status == "verified":
        kyc.status = "pending"
        kyc.verified_at = None
        kyc.rejected_reason = None

    # Optional: Log change (you can add audit log table later)
    # audit_log = AuditLog(user_id=kyc.user_id, action="updated_documents", details=str(doc_update.dict()))
    # db.add(audit_log)

    db.commit()
    db.refresh(kyc)
    return kyc