# Example snippet to call after finalize() in services/credits.py
from server.services.metrics import inc_credits
inc_credits(tenant_id=tenant_id, reason_code='message', units=entry.units)
