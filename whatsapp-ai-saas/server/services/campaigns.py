from sqlalchemy.orm import Session
from sqlalchemy import select
from datetime import datetime
from typing import List, Optional
from ..models import Campaign, CampaignRecipient, Lead
from .metrics import campaign_sends_total

class CampaignService:
    @staticmethod
    def create(db: Session, data) -> Campaign:
        camp = Campaign(**data.model_dump())
        db.add(camp)
        db.commit()
        db.refresh(camp)
        # Pre-compute recipients from audience_filter_json (simple example: all leads for tenant)
        tenant_id = camp.tenant_id
        leads = db.query(Lead).filter(Lead.tenant_id==tenant_id).all()
        for L in leads:
            db.add(CampaignRecipient(campaign_id=camp.id, lead_id=L.id, send_status="Pending"))
        db.commit()
        return camp

    @staticmethod
    def get(db: Session, id: int) -> Optional[Campaign]:
        return db.query(Campaign).get(id)

    @staticmethod
    def recipients(db: Session, id: int, status: Optional[str]=None) -> List[CampaignRecipient]:
        q = db.query(CampaignRecipient).filter(CampaignRecipient.campaign_id==id)
        if status:
            q = q.filter(CampaignRecipient.send_status==status)
        return q.order_by(CampaignRecipient.id.asc()).all()

    @staticmethod
    def mark_in_progress(db: Session, camp: Campaign):
        camp.status = "InProgress"
        db.commit()
        db.refresh(camp)

    @staticmethod
    def mark_paused(db: Session, camp: Campaign):
        camp.status = "Paused"
        db.commit()
        db.refresh(camp)
