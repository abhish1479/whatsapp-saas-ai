# RAG Safety & Versioning Policy
- Namespace per tenant: `tenant::{tenant_id}`
- Collections: `kb-public`, `kb-private`, `faq`, `catalog`
- Required metadata: source_url, version, language, updated_at
- Keep last 3 versions, mark is_active
- Retrieval: hybrid → top-20 → rerank → top-6
- If no source: **Graceful Defer** (collect details, tag needs_human_followup)
- Pre-send moderation on draft; HOLD + alert if flagged
- Log retrieval IDs & scores under trace_id
