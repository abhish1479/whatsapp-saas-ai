import csv
import io
import re
import requests
from sqlalchemy.orm import Session
from datetime import datetime
from models import BusinessProfile, Campaign, Lead, CampaignRecipient, Template
# Assuming you have a unified sender function
from deps import SessionLocal
from sqlalchemy import case, func
from services.exotel_api import send_template_with_media
from settings import settings 

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

ERP_BASE_URL = settings.ERP_URL
ERP_API_KEY = settings.ERP_ADMIN_API_KEY
ERP_API_SECRET =settings.ERP_ADMIN_API_SECRET

def get_erp_headers():
    return {
        "Authorization": f"token {ERP_API_KEY}:{ERP_API_SECRET}",
        "Content-Type": "application/json"
    }

def process_campaign_run_erp(campaign_id: str):
    """
    Full logic to run a campaign using ERPNext as the data source.
    """
    print(f"--- Starting Campaign Run for ID: {campaign_id} ---")

    try:
        # ---------------------------------------------------------
        # 1. FETCH CAMPAIGN & LEADS FROM ERPNEXT
        # ---------------------------------------------------------
        # We use the API 'get_campaign_details' to get everything in one call
        url = f"{ERP_BASE_URL}/api/method/mymobi_whatsapp_saas.mymobi_whatsapp_saas.api.campaign.get_campaign_details"
        response = requests.get(url, params={"campaign_id": campaign_id}, headers=get_erp_headers())
        
        if response.status_code != 200:
            print(f"Error fetching data from ERPNext: {response.text}")
            return

        data = response.json().get("message", {})
        campaign = data.get("campaign") # Dictionary of campaign fields
        leads = data.get("leads", [])   # List of lead dictionaries

        if not campaign:
            print("Campaign not found.")
            return

        # Validate Status
        # Note: Ensure you added 'Status' field to Campaign DocType as discussed
        current_status = campaign.get("custom_status")
        if current_status not in ["In Progress", "Running", "Created"]: 
            print(f"Campaign is '{current_status}'. Stopping.")
            return

        if not leads:
            print("No leads found for this campaign.")
            # Optional: Call API to set status to 'Completed'
            return

        # ---------------------------------------------------------
        # 2. PREPARE RESOURCES (Template & Sender)
        # ---------------------------------------------------------
        # A. Fetch Sender Number (Logic from your original code)
        sender_number = "919773743558"
        # If you track Tenant ID in ERPNext Campaign, use it here:
        tenant_id = campaign.get("tenant_id") 
        if tenant_id:
             # Assuming you still have local DB for business profiles
             # business_profile = db.query(BusinessProfile).filter(BusinessProfile.tenant_id == tenant_id).first()
             # if business_profile:
             #    sender_number = business_profile.business_whatsapp
             pass

        # B. Fetch Template (Logic from your original code)
        template_body = ""
        tmpl = None
        
        # Assuming you added a 'template_id' field to your ERPNext Campaign DocType
        template_id = campaign.get("custom_template") 
        
        if template_id:
            db = SessionLocal() 
            tmpl = db.query(Template).filter(Template.id == template_id).first()
            if tmpl:
                    template_body = tmpl.body
            db.close()
            
        # FOR TESTING: Fallback if no template logic exists yet
        if not tmpl and not template_body:
            # print("Warning: No template found. Using default text.")
            template_body = "Hello {{name}}, this is a test message from our new ERP system."
        else:
            template_body = tmpl.body if tmpl else ""

        # ---------------------------------------------------------
        # 3. PROCESS EACH LEAD
        # ---------------------------------------------------------
        for lead in leads:
            template_body = tmpl.body if tmpl else ""
            # Filter: Only process 'Open' or 'New' leads
            # Adjust these strings to match your exact ERPNext Lead Status options
            if lead.get("status") not in ["Open", "New" ,"Lead"]:
                continue

            lead_id = lead.get("name")      # ERPNext ID (e.g. LEAD-2025-001)
            phone = lead.get("mobile_no")
            lead_name = lead.get("lead_name") or "Sir/Madam"
            
            if not phone:
                print(f"Skipping {lead_id}: No mobile number.")
                continue

            # A. Prepare Message Content
            # Replace {{name}} with customer name
            template_body = template_body.replace("{{name}}", f"{{{{{lead_name}}}}}")
            # Extract params for WhatsApp API (your regex logic)
            # Note: You need to replace the placeholders with actual values for the API params
            body_params = re.findall(r'\{\{([^}]*)\}\}', template_body)
            # Map params logic here...
            
            # B. Send Message
            try:
                # CALL YOUR SENDING FUNCTION HERE
                success = send_template_with_media(
                            to_number=phone,
                            from_number=sender_number,
                            template_name=tmpl.name if tmpl else None,
                            media_url=tmpl.media_link if tmpl else None,
                            body_params=body_params,
                            language=tmpl.language if tmpl else "en",
                            media_type=tmpl.media_type if tmpl else None
                        )
                
                # Mock success for now
                print(f"Sending to {phone} ({lead_name})...")
               

                # C. Determine New Status
                new_status = "Quotation" if success else "Lost Quotation" # Must match ERPNext Status options

            except Exception as send_error:
                print(f"Failed to send to {phone}: {send_error}")
                new_status = "Lost Quotation"

            # ---------------------------------------------------------
            # 4. UPDATE STATUS IN ERPNEXT
            # ---------------------------------------------------------
            try:
                update_url = f"{ERP_BASE_URL}/api/method/mymobi_whatsapp_saas.mymobi_whatsapp_saas.api.leads.update_lead_status"
                payload = {
                    "lead_id": lead_id,
                    "new_status": new_status
                }
                
                upd_response = requests.post(update_url, json=payload, headers=get_erp_headers())
                
                if upd_response.status_code != 200:
                    print(f"Failed to update ERPNext for {lead_id}: {upd_response.text}")
                
            except Exception as api_error:
                print(f"API Error updating {lead_id}: {api_error}")

    except Exception as e:
        print(f"CRITICAL ERROR: {str(e)}")