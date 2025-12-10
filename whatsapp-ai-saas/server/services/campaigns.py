import csv
import io
import re
from sqlalchemy.orm import Session
from datetime import datetime
from models import BusinessProfile, Campaign, Lead, CampaignRecipient, Template
# Assuming you have a unified sender function
from deps import SessionLocal
from sqlalchemy import case, func
from services.exotel_api import send_template_with_media 

class CampaignService:
    
    @staticmethod
    def calculate_stats(db: Session, campaign_id: int):
        """
        Aggregates stats for a campaign based on the LEAD table status.
        """
        stats = db.query(
            func.count(Lead.id).label('total'),
            func.sum(case((Lead.status == 'Sent', 1), else_=0)).label('sent'),
            func.sum(case((Lead.status == 'New', 1), else_=0)).label('new'),
            func.sum(case((Lead.status == 'Success', 1), else_=0)).label('success'),
            func.sum(case((Lead.status == 'Failed', 1), else_=0)).label('failed'),
        ).filter(Lead.campaign_id == campaign_id).first()
        
        if stats is None or stats.total is None:
            return {
                "total_leads": 0,
                "new": 0,
                "sent": 0,
                "failed": 0,
                "success": 0
            }
        return {
            "total_leads": stats.total or 0,
            "new": stats.new or 0,
            "sent": stats.sent or 0,
            "failed": stats.failed or 0,
            "success": stats.success or 0
        }

    @staticmethod
    def process_campaign_run(campaign_id: int):
        """
        Sends messages to Leads with status 'New'.
        Updates Lead.status and Lead.summary.
        """
        db = SessionLocal() 
        try:
            campaign = db.query(Campaign).filter(Campaign.id == campaign_id).first()
            if not campaign or campaign.status not in ["Running", "Created"]: # Allow running from Created if immediate
              return

        # 1. Fetch Template Body (if applicable)
            template_body = ""
            if campaign.template_id:
                tmpl = db.query(Template).filter(Template.id == campaign.template_id).first()
                if tmpl:
                    template_body = tmpl.body

                    
                # 2. Fetch 'New' Leads for this campaign
                # We process batches to avoid memory issues, though here we do all for simplicity
                leads = db.query(Lead).filter(
                    Lead.campaign_id == campaign_id,
                    Lead.status == "New"
                ).limit(100).all() 

                # If no leads left, mark campaign complete
                if not leads:
                    campaign.status = "Completed"
                    db.commit()
                    return
                
                sender_number = "919773743558" 
                bussiness_profile = db.query(BusinessProfile).filter(BusinessProfile.tenant_id == campaign.tenant_id).first()
                if bussiness_profile:
                    sender_number = bussiness_profile.business_whatsapp

                for lead in leads:
                    # Check if paused externally
                    template_body = tmpl.body
                    
                    db.refresh(campaign)
                    if campaign.status == "Paused":
                        break

                    # 3. Determine Content: Pitch > Campaign Default > Template
                    if not lead.pitch:
                        lead.pitch = campaign.default_pitch
                    
                    if not template_body:
                        lead.status = "Failed"
                        lead.summary = "Error: No content available template"
                        db.commit()
                        continue

                    try:
                        # 4. Send Message
                        cust_name = lead.name if lead.name else "Sir/Madam"
                        template_body = template_body.replace("{{name}}", f"{{{{{cust_name}}}}}")
                        body_params = re.findall(r'\{\{([^}]*)\}\}', template_body)
                        #body_params[body_params.index("name")] = lead.name if lead.name else "Sir/Madam"

                        success = send_template_with_media(
                            to_number=lead.phone,
                            from_number=sender_number,
                            template_name=tmpl.name if tmpl else None,
                            media_url=tmpl.media_link if tmpl else None,
                            body_params=body_params,
                            language=tmpl.language if tmpl else "en",
                            media_type=tmpl.media_type if tmpl else None
                        )

                        if success:
                            lead.status = "Sent"
                            lead.summary = f"Template Message: {template_body}..." # Fill copy in summary
                            
                            # Update Recipient table just for schema consistency (optional)
                            rec = db.query(CampaignRecipient).filter(CampaignRecipient.lead_id == lead.id).first()
                            if rec:
                                rec.send_status = "Sent"
                                rec.send_at = datetime.utcnow()
                        else:
                            lead.status = "Failed"
                            lead.summary = ""

                    except Exception as e:
                        lead.status = "Failed"
                        lead.summary = f"Exception: {str(e)}"
                    
                    db.commit()   
        

        except Exception as e:
          print(f"Error while sending template: {e}")
    
        finally:
            db.close() 
        
        # Check if more leads exist; if so, re-queue or loop (omitted for brevity)