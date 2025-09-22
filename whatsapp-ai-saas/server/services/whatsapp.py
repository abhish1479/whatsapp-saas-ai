# services/whatsapp.py

import os, logging, httpx
from typing import Dict, Any, Optional, Dict as TDict

from services.metrics import provider_errors_total

logger = logging.getLogger(__name__)

# --- Env / defaults ---
WHATSAPP_PROVIDER = os.getenv("WHATSAPP_PROVIDER", "cloud")  # future: 'bsp', etc.
WHATSAPP_API_URL = os.getenv("WHATSAPP_API_URL", "https://graph.facebook.com/v19.0")
WHATSAPP_PHONE_NUMBER_ID = os.getenv("WHATSAPP_PHONE_NUMBER_ID", "")
WHATSAPP_ACCESS_TOKEN = os.getenv("WHATSAPP_ACCESS_TOKEN", "")

# ============================================================
# Provider interface + Cloud API implementation
# ============================================================

class WhatsAppProvider:
    async def send_text(self, tenant_id: str, to: str, text: str) -> Dict[str, Any]:
        raise NotImplementedError

    async def send_template(
        self,
        tenant_id: str,
        to: str,
        template_name: str,
        locale: str = "en_US",
        components: Optional[TDict[str, Any]] = None,
    ) -> Dict[str, Any]:
        raise NotImplementedError


class CloudAPIProvider(WhatsAppProvider):
    def __init__(self, api_url: str, phone_id: str, access_token: str):
        self.api_url = api_url.rstrip("/")
        self.phone_id = phone_id
        self.access_token = access_token

    def _headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
        }

    def _endpoint(self) -> str:
        return f"{self.api_url}/{self.phone_id}/messages"

    async def _post(self, tenant_id: str, payload: Dict[str, Any]) -> Dict[str, Any]:
        url = self._endpoint()
        try:
            async with httpx.AsyncClient(timeout=30) as client:
                resp = await client.post(url, headers=self._headers(), json=payload)
            if 200 <= resp.status_code < 300:
                data = resp.json() if resp.text else {}
                logger.info("[WhatsApp] OK tenant=%s type=%s", tenant_id, payload.get("type"))
                return {"ok": True, "response": data, "error": None}
            provider_errors_total.labels(provider="whatsapp").inc()
            logger.error("[WhatsApp] HTTP %s tenant=%s body=%s",
                         resp.status_code, tenant_id, resp.text)
            return {"ok": False, "response": None, "error": f"HTTP {resp.status_code}: {resp.text}"}
        except Exception as e:
            provider_errors_total.labels(provider="whatsapp").inc()
            logger.exception("[WhatsApp] Exception tenant=%s err=%s", tenant_id, e)
            return {"ok": False, "response": None, "error": str(e)}

    async def send_text(self, tenant_id: str, to: str, text: str) -> Dict[str, Any]:
        payload = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "text",
            "text": {"body": text},
        }
        return await self._post(tenant_id, payload)

    async def send_template(
        self,
        tenant_id: str,
        to: str,
        template_name: str,
        locale: str = "en_US",
        components: Optional[TDict[str, Any]] = None,
    ) -> Dict[str, Any]:
        payload: Dict[str, Any] = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "template",
            "template": {
                "name": template_name,
                "language": {"code": locale},
            },
        }
        if components:
            payload["template"]["components"] = components
        return await self._post(tenant_id, payload)


# Factory expected by routers/provisioning.py
def get_provider(tenant_id: Optional[str] = None) -> WhatsAppProvider:
    """
    Returns a WhatsAppProvider instance.
    Later, you can switch by tenant_id or DB config (BSP vs Cloud).
    """
    provider = (os.getenv("WHATSAPP_PROVIDER") or WHATSAPP_PROVIDER).lower()
    # For now only Cloud API is implemented; fallback to Cloud for unknown values.
    if provider in ("cloud", "cloudapi", "meta"):
        return CloudAPIProvider(
            api_url=WHATSAPP_API_URL,
            phone_id=WHATSAPP_PHONE_NUMBER_ID,
            access_token=WHATSAPP_ACCESS_TOKEN,
        )
    logger.warning("Unknown WHATSAPP_PROVIDER=%s; falling back to Cloud API", provider)
    return CloudAPIProvider(
        api_url=WHATSAPP_API_URL,
        phone_id=WHATSAPP_PHONE_NUMBER_ID,
        access_token=WHATSAPP_ACCESS_TOKEN,
    )

# ============================================================
# Backward compatible convenience function (keeps your old code working)
# ============================================================

async def send_whatsapp_message(
    tenant_id: str,
    to: str,
    text: str,
    template_name: Optional[str] = None,
    locale: str = "en_US",
) -> Dict[str, Any]:
    """
    Existing convenience entry (kept for backward compatibility).
    Uses the provider returned by get_provider().
    """
    prov = get_provider(tenant_id)
    if template_name:
        return await prov.send_template(tenant_id=tenant_id, to=to, template_name=template_name, locale=locale)
    return await prov.send_text(tenant_id=tenant_id, to=to, text=text)
