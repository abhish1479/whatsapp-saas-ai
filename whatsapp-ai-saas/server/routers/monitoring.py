from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from deps import get_db
from models import CampaignRecipient, Lead

router = APIRouter(prefix="/monitor", tags=["Monitoring"])

@router.get("/live")
def live_board(tenant_id: int, db: Session = Depends(get_db)):
    # Simple snapshot: latest 100 updates
    rows = (db.query(CampaignRecipient, Lead)
              .join(Lead, Lead.id==CampaignRecipient.lead_id)
              .order_by(CampaignRecipient.id.desc())
              .limit(100)
              .all())
    return [{"lead_name": L.name, "phone": L.phone, "status": R.send_status, "last_error": R.error_code} for (R,L) in rows]
