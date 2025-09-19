from prometheus_client import Counter, Gauge, Histogram

credits_spent = Counter("credits_spent_total", "Total credits spent", ["tenant_id","reason_code"])
moderation_blocks = Counter("moderation_blocks_total", "Flagged/blocked messages", ["tenant_id"])
messages_total = Counter("messages_total", "Messages processed", ["tenant_id","direction"])
conversation_active_total = Gauge("conversation_active_total", "Active conversations")
template_sends_total = Counter("template_sends_total", "Templates sent", ["tenant_id","template_name","locale"])
template_replies_total = Counter("template_replies_total", "Replies received after template send", ["tenant_id","template_name","locale"])
provider_errors_total = Counter("provider_errors_total", "Provider errors", ["provider"])
webhook_queue_depth = Gauge("webhook_queue_depth", "Redis stream depth")
first_response_seconds = Histogram("first_response_seconds", "Time to first response seconds", buckets=(0.5,1,2,3,5,8,13,21))

def inc_credits(tenant_id: str, reason_code: str, units: int=1):
    for _ in range(units):
        credits_spent.labels(tenant_id=tenant_id, reason_code=reason_code).inc()

def inc_message(tenant_id: str, direction: str):
    messages_total.labels(tenant_id=tenant_id, direction=direction).inc()
