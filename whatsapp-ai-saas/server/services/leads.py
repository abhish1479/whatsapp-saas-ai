from sqlalchemy.orm import Session
from typing import List, Optional
from models import Lead
from services.metrics import leads_ingested_total

class LeadsService:
    @staticmethod
    def create(db: Session, data) -> Lead:
        lead = Lead(**data.model_dump())
        db.add(lead)
        db.commit()
        db.refresh(lead)
        leads_ingested_total.labels(source="api").inc()
        return lead

    @staticmethod
    def list(db: Session, tenant_id: int, q: Optional[str]=None, tags: Optional[List[str]]=None, status: Optional[str]=None):
        query = db.query(Lead).filter(Lead.tenant_id==tenant_id)
        if q:
            like = f"%{q}%"
            query = query.filter((Lead.name.ilike(like)) | (Lead.phone.ilike(like)) | (Lead.email.ilike(like)))
        if tags:
            # naive tags contains
            query = query.filter(Lead.tags.contains(tags))
        if status:
            query = query.filter(Lead.status==status)
        return query.order_by(Lead.created_at.desc()).all()

    @staticmethod
    def get(db: Session, lead_id: int) -> Optional[Lead]:
        return db.query(Lead).get(lead_id)

    @staticmethod
    def update(db: Session, lead: Lead, data) -> Lead:
        for k,v in data.model_dump(exclude_unset=True).items():
            setattr(lead, k, v)
        db.commit()
        db.refresh(lead)
        return lead
