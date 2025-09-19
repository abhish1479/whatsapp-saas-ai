
import requests
from settings import settings

class WhatsAppProvider:
    def send_text(self, to_e164:str, text:str):
        raise NotImplementedError
    def register_webhook(self, callback_url:str):
        return 200, "ok"

class Dialog360Provider(WhatsAppProvider):
    def __init__(self):
        self.base = settings.DIALOG360_BASE_URL.rstrip('/')
        self.api_key = settings.DIALOG360_API_KEY
    def send_text(self, to_e164:str, text:str):
        url = f"{self.base}/v1/messages"
        headers = {"D360-API-KEY": self.api_key, "Content-Type":"application/json"}
        payload = {"to": to_e164, "type":"text", "text":{"body":text}}
        resp = requests.post(url, headers=headers, json=payload, timeout=20)
        return (resp.status_code, resp.text)

class CloudAPIProvider(WhatsAppProvider):
    def __init__(self):
        self.base = settings.WA_CLOUD_BASE_URL.rstrip('/')
        self.token = settings.WA_CLOUD_TOKEN
        self.phone_id = settings.WA_CLOUD_PHONE_ID
    def send_text(self, to_e164:str, text:str):
        url = f"{self.base}/{self.phone_id}/messages"
        headers = {"Authorization": f"Bearer {self.token}"}
        payload = {"messaging_product":"whatsapp","to":to_e164,"type":"text","text":{"body":text}}
        resp = requests.post(url, headers=headers, json=payload, timeout=20)
        return (resp.status_code, resp.text)

def get_provider()->WhatsAppProvider:
    if settings.WA_PROVIDER == "cloud":
        return CloudAPIProvider()
    return Dialog360Provider()
