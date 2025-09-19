
from fastapi import APIRouter, Depends, UploadFile, File
from pydantic import BaseModel
from database import SessionLocal
from models import Lead
from deps import get_current
import csv, io

router = APIRouter()

class LeadReq(BaseModel):
    name:str|None=None
    phone:str
    notes:str|None=None

@router.post("/add")
def add_lead(body:LeadReq, ident=Depends(get_current)):
    db = SessionLocal()
    try:
        lead = Lead(tenant_id=ident['tid'], name=body.name, phone=body.phone, notes=body.notes, source="manual")
        db.add(lead); db.commit()
        return {"id": lead.id}
    finally:
        db.close()

@router.post("/upload_csv")
async def upload_csv(file:UploadFile = File(...), ident=Depends(get_current)):
    db = SessionLocal()
    try:
        content = await file.read()
        reader = csv.DictReader(io.StringIO(content.decode()))
        count=0
        for row in reader:
            lead = Lead(tenant_id=ident['tid'], name=row.get('name'), phone=row.get('phone'), notes=row.get('notes'), source="csv")
            db.add(lead); count+=1
        db.commit()
        return {"imported": count}
    finally:
        db.close()
