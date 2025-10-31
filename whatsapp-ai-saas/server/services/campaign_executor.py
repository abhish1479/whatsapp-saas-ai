from sqlalchemy.orm import Session
from datetime import datetime
from models import Campaign, CampaignRecipient, Lead
from services.whatsapp import WhatsAppProvider
from services.credits import CreditsService
from services.metrics import campaign_sends_total
from services.scheduling import within_quiet_hours, next_allowed_time

provider = WhatsAppProvider()
credits = CreditsService()

def execute_batch(db: Session, campaign_id: int, batch_size: int = 50):
    camp = db.query(Campaign).get(campaign_id)
    if not camp or camp.status not in ("InProgress", "Scheduled"):
        return {"processed":0}

    qs = (db.query(CampaignRecipient)
            .filter(CampaignRecipient.campaign_id==campaign_id, CampaignRecipient.send_status=="Pending")
            .order_by(CampaignRecipient.id.asc())
            .limit(batch_size))
    rows = qs.all()
    processed = 0
    for rec in rows:
        lead = db.query(Lead).get(rec.lead_id)
        if not lead or lead.status == "DND":
            rec.send_status = "Error"
            rec.error_code = "DND_OR_MISSING"
            db.commit()
            continue

        # Quiet hours check (assuming tenant/lead local already normalized)
        now = datetime.utcnow()
        if within_quiet_hours(now):
            rec.send_at = next_allowed_time(now)
            db.commit()
            continue

        # Credits reserve
        if not credits.reserve(tenant_id=camp.tenant_id, units=1, reason="template", key=f"rec_{rec.id}"):
            camp.status = "Paused"
            db.commit()
            break

        # Prepare message (template or text)
        if camp.template_id:
            result = provider.send_template(lead.phone, camp.template_id, params={})
        else:
            text = (lead.pitch or camp.default_pitch or "Hi!")
            result = provider.send_text(lead.phone, text)

        # Update status
        rec.send_status = "Sent"
        rec.send_at = now
        rec.meta = {"provider_id": result.get("message_id"), "template_id": camp.template_id}
        db.commit()
        processed += 1
        campaign_sends_total.labels(campaign_id=str(campaign_id), template=str(camp.template_id or "text")).inc()

    return {"processed": processed}
