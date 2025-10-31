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

leads_ingested_total = Counter("leads_ingested_total", "Total leads ingested", ["source"])
leads_validated_total = Counter("leads_validated_total", "Leads validated", ["result"])
campaign_sends_total = Counter("campaign_sends_total", "Campaign sends", ["campaign_id", "template"])
deliveries_total = Counter("deliveries_total", "Deliveries total", ["provider", "code"])
reads_total = Counter("reads_total", "Reads total", ["provider"])
replies_total = Counter("replies_total", "Replies total", ["provider"])
conversions_total = Counter("conversions_total", "Conversions total", ["campaign_id"])
credits_burn_total = Counter("credits_burn_total", "Credits burned", ["reason"])
moderation_holds_total = Counter("moderation_holds_total", "Moderation holds", ["reason"])
active_conversations_gauge = Gauge("active_conversations_gauge", "Active conversations", ["tenant_id"])
avg_first_response_seconds = Histogram("avg_first_response_seconds", "First response seconds", ["campaign_id"])
executor_latency_seconds = Histogram("executor_latency_seconds", "Executor latency seconds", ["campaign_id"])

def inc_credits(tenant_id: str, reason_code: str, units: int=1):
    for _ in range(units):
        credits_spent.labels(tenant_id=tenant_id, reason_code=reason_code).inc()

def inc_message(tenant_id: str, direction: str):
    messages_total.labels(tenant_id=tenant_id, direction=direction).inc()
