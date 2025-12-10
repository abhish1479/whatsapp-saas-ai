import asyncio
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
import csv
import io

from deps import get_db
from models import Campaign, Lead, Template
from data_models.campaign_req_res import CampaignListResponse, CampaignDetailResponse, CampaignStatusUpdate
from services.campaigns import CampaignService

router = APIRouter(prefix="/campaigns", tags=["Campaigns"])

# 1. Create Campaign API
@router.post("/create", response_model=dict)
async def create_campaign(
    background_tasks: BackgroundTasks,
    name: str,
    description: Optional[str] = Form(None), # Maps to default_pitch
    channel: str = Form("WHATSAPP"),
    template_id: Optional[int] = Form(None),
    run_immediate: bool = Form(False),
    tenant_id: int = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    # 1. Create Campaign Object
    new_campaign = Campaign(
        tenant_id=tenant_id,
        name=name,
        default_pitch=description, # Mapping description to default_pitch
        template_id=template_id,
        channel=channel,
        status="Running" if run_immediate else "Draft"
    )
    db.add(new_campaign)
    db.commit()
    db.refresh(new_campaign)

    # 2. Parse CSV and Create Leads
    try:
        contents = await file.read()
        decoded = contents.decode("utf-8")
        reader = csv.DictReader(io.StringIO(decoded))
        
        # leads_objects = []
        # recipients_objects = []

        for row in reader:
            # Basic validation
            if not row.get("phone"):
                continue
                
            existing_lead = db.query(Lead).filter(
                Lead.tenant_id == tenant_id,
                Lead.phone == row.get("phone")
            ).first()

            if existing_lead:
                # Update only the allowed fields
                existing_lead.campaign_id = new_campaign.id
                existing_lead.name = row.get("name") or existing_lead.name
                existing_lead.email = row.get("email") or existing_lead.email
                existing_lead.pitch = row.get("pitch") or existing_lead.pitch
                
            else:
                # Create new lead
                lead = Lead(
                    tenant_id=tenant_id,
                    campaign_id=new_campaign.id,
                    name=row.get("name"),
                    phone=row.get("phone"),  # use normalized version
                    email=row.get("email"),
                    pitch=row.get("pitch"),
                    status="New"
                )
                db.add(lead)
            db.flush() # Flush to get lead.id
           
        
        db.commit()

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Error processing CSV: {str(e)}")

    # 3. Handle Execution
    if run_immediate:
        background_tasks.add_task(CampaignService.process_campaign_run, campaign_id)
        return {"success": True, "message": "Campaign created and execution started", "id": new_campaign.id}
    
    return {"success": True, "message": "Campaign created in Draft mode", "id": new_campaign.id}


# 2. Campaign List API
@router.get("/list", response_model=List[CampaignListResponse])
def list_campaigns(tenant_id: int, db: Session = Depends(get_db)):
    campaigns = db.query(Campaign).filter(Campaign.tenant_id == tenant_id).all()
    
    results = []
    for camp in campaigns:
        # Calculate stats
        stats = CampaignService.calculate_stats(db, camp.id)
        
        results.append(CampaignListResponse(
            id=camp.id,
            name=camp.name,
            channel=camp.channel,
            status=camp.status,
            created_at=camp.created_at,
            **stats # Unpack total, sent, delivered, etc.
        ))
    
    return results


# 3. View Campaign API
@router.get("/get_campaign", response_model=CampaignDetailResponse)
def view_campaign(campaign_id: int, db: Session = Depends(get_db)):
    camp = db.query(Campaign).filter(Campaign.id == campaign_id).first()
    if not camp:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    stats = CampaignService.calculate_stats(db, camp.id)
    
    # Get template name if exists
    template_name = None
    if camp.template_id:
        tmpl = db.query(Template).filter(Template.id == camp.template_id).first()
        if tmpl:
            template_name = tmpl.name

    return CampaignDetailResponse(
        id=camp.id,
        name=camp.name,
        status=camp.status,
        created_at=camp.created_at,
        default_pitch=camp.default_pitch,
        channel=camp.channel,
        template_name=template_name,
        **stats
    )


# 4. Start/Pause API
@router.post("/update_status")
def change_campaign_status(
    campaign_id: int, 
    payload: CampaignStatusUpdate, 
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    camp = db.query(Campaign).filter(Campaign.id == campaign_id).first()
    if not camp:
        raise HTTPException(status_code=404, detail="Campaign not found")

    if payload.action == "start":
        if camp.status == "Completed":
             return {"success": False, "message": "Campaign is already completed"}
             
        camp.status = "Running"
        db.commit()
        # Trigger sending logic
        background_tasks.add_task(CampaignService.process_campaign_run, campaign_id)
        message = "Campaign started successfully"

    elif payload.action == "pause":
        camp.status = "Paused"
        db.commit()
        message = "Campaign paused"
    
    return {"success": True, "message": message, "current_status": camp.status}