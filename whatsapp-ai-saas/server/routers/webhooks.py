
from fastapi import APIRouter, Request
from database import SessionLocal
from models import Conversation, Message
from services.credits import debit
from settings import settings
from datetime import datetime

router = APIRouter()

@router.post("/wa")
async def wa_webhook(req:Request):
    payload = await req.json()
    tenant_id = int(payload.get("tenant_id", 1))
    from_phone = payload.get("from")
    text = payload.get("text", "")
    db = SessionLocal()
    try:
        conv = db.query(Conversation).filter_by(tenant_id=tenant_id, phone=from_phone).first()
        if not conv:
            conv = Conversation(tenant_id=tenant_id, phone=from_phone, last_msg_at=datetime.utcnow(), state={})
            db.add(conv); db.flush()
        msg = Message(conversation_id=conv.id, direction="in", text=text, meta=payload, cost_credits=(settings.CREDIT_COST_TEXT if settings.DEDUCT_ON_RECEIVE else 0))
        db.add(msg)
        if settings.DEDUCT_ON_RECEIVE:
            try: debit(db, tenant_id, settings.CREDIT_COST_TEXT, "inbound_message", ref_id=from_phone)
            except: pass
        db.commit()
        return {"ok": True}
    finally:
        db.close()
