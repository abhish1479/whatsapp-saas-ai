# server/services/whatsapp.py

import os, logging, httpx
from typing import Dict, Any, Optional
from server.services.metrics import provider_errors_total

logger = logging.getLogger(__name__)

WHATSAPP_API_URL = os.getenv("WHATSAPP_API_URL", "https://graph.facebook.com/v19.0")
WHATSAPP_PHONE_NUMBER_ID = os.getenv("WHATSAPP_PHONE_NUMBER_ID", "")
WHATSAPP_ACCESS_TOKEN = os.getenv("WHATSAPP_ACCESS_TOKEN", "")


async def send_whatsapp_message(
    tenant_id: str,
    to: str,
    text: str,
    template_name: Optional[str] = None,
    locale: str = "en_US",
) -> Dict[str, Any]:
    """
    Send a WhatsApp message via Cloud API (or BSP).
    - tenant_id: who is sending
    - to: recipient phone number
    - text: message body
    - template_name: if sending a template outside 24h
    - locale: template locale

    Returns dict: { ok: bool, response: dict | None, error: str | None }
    """

    headers = {
        "Authorization": f"Bearer {WHATSAPP_ACCESS_TOKEN}",
        "Content-Type": "application/json",
    }

    # Choose body depending on free-text vs template
    if template_name:
        payload = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "template",
            "template": {
                "name": template_name,
                "language": {"code": locale},
            },
        }
    else:
        payload = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "text",
            "text": {"body": text},
        }

    url = f"{WHATSAPP_API_URL}/{WHATSAPP_PHONE_NUMBER_ID}/messages"

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.post(url, headers=headers, json=payload)
            if resp.status_code >= 200 and resp.status_code < 300:
                data = resp.json()
                logger.info(
                    f"[WhatsApp] Sent to={to} tenant={tenant_id} template={template_name} ok"
                )
                return {"ok": True, "response": data, "error": None}
            else:
                provider_errors_total.labels(provider="whatsapp").inc()
                logger.error(
                    f"[WhatsApp] Failed tenant={tenant_id} to={to} status={resp.status_code} body={resp.text}"
                )
                return {
                    "ok": False,
                    "response": None,
                    "error": f"HTTP {resp.status_code}: {resp.text}",
                }
    except Exception as e:
        provider_errors_total.labels(provider="whatsapp").inc()
        logger.exception(
            f"[WhatsApp] Exception sending tenant={tenant_id} to={to}: {e}"
        )
        return {"ok": False, "response": None, "error": str(e)}
