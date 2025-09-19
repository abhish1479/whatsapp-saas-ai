
from settings import settings

BANNED = {"porn","hate","bomb","terror","drugs"}

def is_unsafe(text:str)->bool:
    if not settings.MODERATION_ENABLED:
        return False
    t = (text or "").lower()
    return any(w in t for w in BANNED)

def safe_fallback()->str:
    return "I can't help with that. Please ask something else."
