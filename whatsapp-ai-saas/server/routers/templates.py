
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from database import SessionLocal
from deps import get_current
from models import Template

router = APIRouter()

class TemplateReq(BaseModel):
    name:str
    language:str="en"
    category:str="MARKETING"
    body:str

@router.post("")
def create_template(body:TemplateReq, ident=Depends(get_current)):
    db = SessionLocal()
    try:
        t = Template(tenant_id=ident['tid'], name=body.name, language=body.language, category=body.category, body=body.body, status="submitted")
        db.add(t); db.commit()
        return {"id": t.id, "status": t.status}
    finally:
        db.close()

@router.get("")
def list_templates(ident=Depends(get_current)):
    db = SessionLocal()
    try:
        rows = db.query(Template).filter_by(tenant_id=ident['tid']).all()
        return rows
    finally:
        db.close()
