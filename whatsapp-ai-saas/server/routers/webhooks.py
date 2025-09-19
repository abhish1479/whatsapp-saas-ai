# server/routers/webhooks.py

from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import JSONResponse
import os, json, time
import aioredis

router = APIRouter(prefix="/webhooks", tags=["webhooks"])

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
QUEUE_KEY = os.getenv("WEBHOOK_QUEUE", "wh_inbound_queue")
VERIFY_TOKEN = os.getenv("WHATSAPP_VERIFY_TOKEN", "change-me")


async def get_redis():
    return await aioredis.from_url(REDIS_URL, decode_responses=True)


@router.get("/whatsapp")
async def whatsapp_verify(mode: str | None = None, challenge: str | None = None, token: str | None = None):
    """WhatsApp webhook verification handshake."""
    if mode == "subscribe" and token == VERIFY_TOKEN:
        return JSONResponse(content=challenge or "ok")
    raise HTTPException(status_code=403, detail="Forbidden")


@router.post("/whatsapp")
async def whatsapp_inbound(req: Request):
    """Receive inbound message from WhatsApp and enqueue it."""
    body = await req.body()
    try:
        payload = json.loads(body.decode("utf-8"))
    except Exception:
        raise HTTPException(400, detail="Invalid JSON")

    # Generate unique event id
    entry = payload.get("entry", [{}])[0]
    event_id = f"{entry.get('id','evt')}:{int(time.time()*1000)}"

    # Push into Redis stream
    r = await get_redis()
    await r.xadd(
        QUEUE_KEY,
        {"event_id": event_id, "payload": json.dumps(payload, separators=(',',':'))},
    )

    return {"status": "queued", "event_id": event_id}
