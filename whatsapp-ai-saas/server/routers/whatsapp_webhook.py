from fastapi import APIRouter, Depends, Request
from fastapi.responses import Response
from sqlalchemy import desc
from services.ai_model import process_message_background
import asyncio
from fastapi import Request
from fastapi.responses import Response
from models import Lead
from sqlalchemy.orm import Session
from deps import get_db
from datetime import datetime, timezone

router = APIRouter(tags=["webhooks"])

@router.post("/whatsapp_webhook")
async def whatsapp_webhook(request: Request):
    print("=" * 60)
    print("[WEBHOOK] New request received from Exotel")
    
    # Log request details
    content_type = request.headers.get('content-type', '')
    print(f"[REQUEST] Content-Type: {content_type}")
    
    user_input = ""
    sender = ""
    receiver = ""  # This will be your Exotel number
    
    # Handle JSON data from Exotel
    if 'application/json' in content_type.lower():
        try:
            json_data = await request.json()
            print(f"[REQUEST] JSON  {json_data}")
            
            # Extract data from Exotel's nested JSON structure
            if 'whatsapp' in json_data and 'messages' in json_data['whatsapp']:
                message = json_data['whatsapp']['messages'][0]
                callback_type = message.get('callback_type', '')
                
                print(f"[EXOTEL] Callback Type: {callback_type}")
                
                # Only process incoming messages, not delivery reports
                if callback_type == 'incoming_message':
                    sender = message.get('from', '')
                    receiver = message.get('to', '')  # Your Exotel number
                    timestamp = message.get('timestamp', '')
                    
                    # Extract message content
                    content = message.get('content', {})
                    content_type = content.get('type', '')
                    
                    if content_type == 'text':
                        user_input = content.get('text', {}).get('body', '').strip()
                    elif content_type == 'image':
                        user_input = "Image received"
                    elif content_type == 'audio':
                        user_input = "Voice message received"
                    elif content_type == 'interactive':
                        user_input = "Interactive message received"
                    
                    print(f"[EXOTEL PARSED] From: {sender}")
                    print(f"[EXOTEL PARSED] To: {receiver}")
                    print(f"[EXOTEL PARSED] Text: {user_input!r}")
                    print(f"[EXOTEL PARSED] Content Type: {content_type}")
                    
                    # Process message in background
                    if sender and user_input:
                        # Schedule background processing
                        asyncio.create_task(process_message_background(sender, receiver, user_input, content))
                else:
                    print(f"[EXOTEL] Skipping callback type: {callback_type}")
            
        except Exception as e:
            print(f"[ERROR] Failed to parse JSON: {e}")
    else:
        print("[ERROR] Unexpected content type, expected JSON")
    
    # IMPORTANT: Return 200 OK immediately
    # Don't process the message here, do it in background
    return Response(content="", media_type="text/plain", status_code=200)




@router.post("/callback_webhook")
async def callback_webhook(request: Request, db: Session = Depends(get_db)):
    print("=" * 60)
    print("[WEBHOOK] New request received from Exotel")
    
    content_type = request.headers.get('content-type', '')
    
    if 'application/json' in content_type.lower():
        try:
            json_data = await request.json()
            print(f"[REQUEST] JSON: {json_data}")
            
            if 'whatsapp' in json_data and 'messages' in json_data['whatsapp']:
                message = json_data['whatsapp']['messages'][0]
                callback_type = message.get('callback_type', '')
                
                print(f"[EXOTEL] Callback Type: {callback_type}")
                
                # --- CASE 1: DELIVERY REPORT (DLR) ---
                if callback_type == 'dlr':
                    recipient_phone = message.get('to', '') # e.g., +918377843261
                    detailed_status = message.get('exo_detailed_status', '') # e.g., EX_MESSAGE_SENT or ..._ERROR
                    description = message.get('description', '')
                    search_phone = recipient_phone[-10:]
                    # 1. Find the most recent Lead by Phone Number
                    # We use order_by(desc) to get the latest lead if duplicates exist
                    lead = db.query(Lead).filter(
                            Lead.phone.like(f"%{search_phone}")
                        ).order_by(desc(Lead.created_at)).first()

                    # if lead:
                    #     print(f"[DB] Found Lead ID: {lead.id} for Phone: {recipient_phone}")
                        
                    #     # 2. Check for Failure
                    #     # We check if 'ERROR' or 'FAILED' is in the status string
                        
                    #     # 3. Check for Success (Sent, Delivered, Read)
                    #     if any(s in detailed_status for s in ['SENT', 'DELIVERED', 'READ','SEEN']):
                    #         print(f"[STATUS] Marking as Success: {detailed_status}")
                            
                    #         # You can set this to "Success" or keep it granular (Sent/Delivered)
                    #         # Per your request, setting to "Success"
                    #         lead.status = "Success"
                    #     else:
                    #         print(f"[STATUS] Marking as Failed: {description}")
                            
                    #         lead.status = "Failed"
                    #         # Append failure reason to summary
                    #         current_summary = lead.pitch if lead.pitch else ""
                    #         # Format: "Old Summary | Failed: Reason"
                    #         new_summary = f"{current_summary} | Failed: {description}".strip(" |")
                    #         lead.pitch = new_summary 
                            
                    #     # Commit changes
                    #     db.commit()
                    #     db.refresh(lead)
                    # else:
                    #     print(f"[DB] No lead found for phone number: {recipient_phone}")

                    if lead:
                        print(f"[DB] Found Lead ID: {lead.id} for Phone: {recipient_phone}")
                        
                        # Initialize tags if not present
                        if lead.tags is None:
                            lead.tags = []

                        # Get current UTC timestamp in ISO format
                        now = datetime.now(timezone.utc).isoformat()

                        # Track statuses of interest
                        success_statuses = ['SENT', 'DELIVERED', 'READ', 'SEEN']
                        existing_statuses = {item.get('status') for item in lead.tags if isinstance(item, dict)}

                        # Check for Success
                        matched_success = [s for s in success_statuses if s in detailed_status]
                        
                        if matched_success:
                            print(f"[STATUS] Marking as Success: {detailed_status}")
                            lead.status = "Success"

                            # Add new status entries to tags (avoid duplicates)
                            for s in matched_success:
                                if s not in existing_statuses:
                                    lead.tags.append({"status": s, "timestamp": now})
                        else:
                            print(f"[STATUS] Marking as Failed: {description}")
                            lead.status = "Failed"
                            current_summary = lead.pitch or ""
                            new_summary = f"{current_summary} | Failed: {description}".strip(" |")
                            lead.pitch = new_summary

                        # Commit changes
                        db.commit()
                        db.refresh(lead)
                    else:
                        print(f"[DB] No lead found for phone number: {recipient_phone}")

                # --- CASE 2: INCOMING MESSAGE ---
                elif callback_type == 'incoming_message':
                    sender = message.get('from', '')
                    content = message.get('content', {})
                    msg_type = content.get('type', '')
                    
                    user_input = ""
                    if msg_type == 'text':
                        user_input = content.get('text', {}).get('body', '').strip()
                    else:
                        user_input = f"[{msg_type} message]"
                    
                    print(f"[INCOMING] From: {sender} | Text: {user_input}")
                    # Your incoming message logic here...

                else:
                    print(f"[EXOTEL] Unhandled callback type: {callback_type}")
            
        except Exception as e:
            print(f"[ERROR] Processing Webhook: {e}")
    else:
        print("[ERROR] Unexpected content type, expected JSON")

    return Response(content="", media_type="text/plain", status_code=200)