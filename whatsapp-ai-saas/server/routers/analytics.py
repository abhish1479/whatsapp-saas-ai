
from fastapi import APIRouter, Depends
from deps import get_current
from database import SessionLocal
from models import Lead, Message
from sqlalchemy import func

router = APIRouter()

@router.get("/summary")
def summary(ident=Depends(get_current)):
    db = SessionLocal()
    try:
        leads_total = db.query(Lead).filter(Lead.tenant_id==ident['tid']).count()
        msgs = db.query(func.count(Message.id)).scalar() or 0
        return {"leads_total": leads_total, "messages_total": msgs}
    finally:
        db.close()
