# WhatsApp Number Provisioning Journey (SOP)
KYC Artifacts:
- Business legal name, address, website, support email
- Registration docs (GST/Company Reg)
- FB Business Manager verification (if Cloud API)
- Display names & templates per locale

SLAs:
- Name approval: 24–72h
- Number activation: 24–72h
- Template approval: 24–48h per locale

Flow:
1) Collect KYC + verify BM
2) Reserve/attach number
3) Submit display name → wait approval
4) Submit templates per `session_templates.yaml`
5) QA send test to sandbox lead
6) Handover

Fallbacks:
- BSP stalls >72h → switch to Cloud API temporarily
- Template rejected → fallback to generic template
- Phone quality drop → throttle campaigns, alert

Failure Paths:
- KYC rejected → request fixes
- Template rejected → capture reviewer comments
- Connectivity errors → failover if configured
