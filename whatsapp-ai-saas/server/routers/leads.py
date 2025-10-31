from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlalchemy.orm import Session
from ..database import get_db
from ..data_models.schemas import LeadCreate, LeadUpdate, LeadOut
from ..services.leads import LeadsService

router = APIRouter(prefix="/leads", tags=["Leads"])

@router.post("", response_model=LeadOut, status_code=201)
def create_lead(payload: LeadCreate, db: Session = Depends(get_db)):
    return LeadsService.create(db, payload)

@router.get("", response_model=list[LeadOut])
def list_leads(tenant_id: int = Query(...), q: str | None = None, status: str | None = None, db: Session = Depends(get_db)):
    return LeadsService.list(db, tenant_id=tenant_id, q=q, status=status)

@router.get("/{lead_id}", response_model=LeadOut)
def get_lead(lead_id: int, db: Session = Depends(get_db)):
    lead = LeadsService.get(db, lead_id)
    if not lead:
        raise HTTPException(404, "Lead not found")
    return lead

@router.patch("/{lead_id}", response_model=LeadOut)
def update_lead(lead_id: int, payload: LeadUpdate, db: Session = Depends(get_db)):
    lead = LeadsService.get(db, lead_id)
    if not lead:
        raise HTTPException(404, "Lead not found")
    return LeadsService.update(db, lead, payload)
