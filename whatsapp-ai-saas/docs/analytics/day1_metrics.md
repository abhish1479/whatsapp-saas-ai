# Day-1 Analytics
Charts:
1) First Response Time (p50/p95) -> histogram `first_response_seconds_bucket`
2) Session Reopen Rate -> `rate(conversations_reopened_total[5m])`
3) Template CTR -> `template_replies_total / template_sends_total`
4) Credit Burn by Source -> `sum by (reason_code)(rate(credits_spent_total[5m]))`
5) Moderation Hold Rate -> `rate(moderation_blocks_total[5m])`
6) Errors by Provider -> `sum by (provider)(rate(provider_errors_total[5m]))`
7) Webhook Queue Depth -> `webhook_queue_depth`
8) Active Conversations -> `conversation_active_total`
9) Messages per Tenant -> `sum by (tenant_id)(rate(messages_total[5m]))`
10) Credits Remaining (Wallet) -> exporter gauge `wallet_balance{tenant_id}`

Log Fields:
trace_id, tenant_id, conversation_id, event_id, direction, template_name, locale, credits, reason_code, moderation_flag, provider, latency_ms
