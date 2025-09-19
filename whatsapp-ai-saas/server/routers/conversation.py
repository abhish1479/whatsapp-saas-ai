
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from deps import get_current
from services.whatsapp import get_provider
from services.moderation import is_unsafe
from services.credits import debit
from database import SessionLocal
from models import Conversation, Message
from sqlalchemy.orm import Session
from settings import settings
from datetime import datetime

router = APIRouter()

class SendReq(BaseModel):
    phone:str
    message:str

@router.post("/send")
def send_message(body:SendReq, ident=Depends(get_current)):
    if is_unsafe(body.message): 
        raise HTTPException(400, "Message blocked by moderation")

    prov = get_provider()
    status_code, resp_text = prov.send_text(body.phone, body.message)

    db = SessionLocal()
    try:
        try:
            debit(db, ident['tid'], settings.CREDIT_COST_TEXT, "send_message", ref_id=body.phone)
        except Exception as e:
            raise HTTPException(402, f"Credits error: {e}")
        conv = db.query(Conversation).filter_by(tenant_id=ident['tid'], phone=body.phone).first()
        if not conv:
            conv = Conversation(tenant_id=ident['tid'], phone=body.phone, last_msg_at=datetime.utcnow(), state={})
            db.add(conv); db.flush()
        msg = Message(conversation_id=conv.id, direction="out", text=body.message, meta={"provider_resp":resp_text}, cost_credits=settings.CREDIT_COST_TEXT)
        db.add(msg); db.commit()
        return {"ok": True, "provider_status": status_code}
    finally:
        db.close()
