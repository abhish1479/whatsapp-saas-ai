
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from deps import get_current
from database import SessionLocal
from models import Number
from services.whatsapp import get_provider

router = APIRouter()

class ProvisionReq(BaseModel):
    use_existing: bool = False
    phone: str | None = None

@router.post("/number")
def provision_number(req:ProvisionReq, ident=Depends(get_current)):
    db = SessionLocal()
    try:
        num = Number(tenant_id=ident['tid'], provider="dialog360", wa_phone=req.phone or "TEST", wa_id="NA", status="active")
        db.add(num); db.commit()
        prov = get_provider()
        prov.register_webhook(callback_url="https://yourdomain/webhooks/wa")
        return {"status":"active","phone":num.wa_phone}
    finally:
        db.close()
