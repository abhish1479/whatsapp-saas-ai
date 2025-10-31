from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from rq import Queue
from redis import Redis
from ..database import get_db
from ..data_models.schemas import CampaignCreate, CampaignOut, LaunchRequest, RecipientOut
from ..services.campaigns import CampaignService
from ..services.campaign_executor import execute_batch
from ..settings import settings

router = APIRouter(prefix="/campaigns", tags=["Campaigns"])

redis_conn = Redis.from_url(settings.REDIS_URL)
queue = Queue("campaigns", connection=redis_conn)

@router.post("", response_model=CampaignOut, status_code=201)
def create_campaign(payload: CampaignCreate, db: Session = Depends(get_db)):
    return CampaignService.create(db, payload)

@router.post("/{campaign_id}/launch", response_model=CampaignOut)
def launch_campaign(campaign_id: int, payload: LaunchRequest, db: Session = Depends(get_db)):
    camp = CampaignService.get(db, campaign_id)
    if not camp:
        raise HTTPException(404, "Campaign not found")
    CampaignService.mark_in_progress(db, camp)
    # enqueue executor job
    job = queue.enqueue(execute_batch, db, campaign_id, settings.EXECUTOR_BATCH_SIZE, job_timeout=600)
    return camp

@router.get("/{campaign_id}", response_model=CampaignOut)
def get_campaign(campaign_id: int, db: Session = Depends(get_db)):
    camp = CampaignService.get(db, campaign_id)
    if not camp:
        raise HTTPException(404, "Campaign not found")
    return camp

@router.get("/{campaign_id}/recipients", response_model=list[RecipientOut])
def list_recipients(campaign_id: int, status: str | None = None, db: Session = Depends(get_db)):
    return CampaignService.recipients(db, campaign_id, status=status)
