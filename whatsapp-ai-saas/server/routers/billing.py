
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel
from deps import get_current
from database import SessionLocal
from services.credits import credit, ensure_wallet
from settings import settings
import razorpay, hmac, hashlib, json

router = APIRouter()

@router.get("/packs")
def list_packs(ident=Depends(get_current)):
    return [{"id":p["id"], "amount":p["amount"], "credits":p["credits"], "label":p["label"], "currency":settings.CURRENCY} for p in settings.PACKS]

class OrderReq(BaseModel):
    pack_id: str

@router.post("/create_order")
def create_order(body:OrderReq, ident=Depends(get_current)):
    pack = next((p for p in settings.PACKS if p["id"] == body.pack_id), None)
    if not pack: raise HTTPException(404,"Pack not found")
    if not settings.RAZORPAY_KEY_ID or not settings.RAZORPAY_KEY_SECRET:
        raise HTTPException(400, "Razorpay keys not configured")
    client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))
    order = client.order.create({
        "amount": pack["amount"],
        "currency": settings.CURRENCY,
        "receipt": f"{ident['tid']}::{pack['id']}",
        "notes": {"tenant_id": str(ident['tid']), "pack_id": pack["id"]}
    })
    return {"order": order, "key_id": settings.RAZORPAY_KEY_ID}

def verify_signature(body:bytes, signature:str):
    digest = hmac.new(settings.RAZORPAY_WEBHOOK_SECRET.encode("utf-8"), body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(digest, signature or "")

@router.post("/webhook")
async def razorpay_webhook(request:Request):
    if not settings.RAZORPAY_WEBHOOK_SECRET:
        raise HTTPException(400,"Webhook secret not configured")
    body = await request.body()
    signature = request.headers.get("X-Razorpay-Signature","")
    if not verify_signature(body, signature):
        raise HTTPException(401,"Invalid signature")
    event = json.loads(body.decode())

    # Try to resolve tenant_id & pack from payload
    notes = event.get("payload",{}).get("order",{}).get("entity",{}).get("notes",{}) or             event.get("payload",{}).get("payment",{}).get("entity",{}).get("notes",{})
    receipt = event.get("payload",{}).get("order",{}).get("entity",{}).get("receipt","")
    pack_id = (notes or {}).get("pack_id") or (receipt.split("::")[1] if "::" in receipt else None)
    tenant_id = int((notes or {}).get("tenant_id") or (receipt.split("::")[0] if "::" in receipt else 0))
    pack = next((p for p in settings.PACKS if p["id"] == pack_id), None)
    if not (pack and tenant_id):
        return {"ignored": True}

    db = SessionLocal()
    try:
        ensure_wallet(db, tenant_id)
        credit(db, tenant_id, pack["credits"], f"razorpay:{pack_id}")
    finally:
        db.close()
    return {"ok": True, "credited": pack["credits"]}
