import os
from typing import Any, Dict, List, Optional
from fastapi import Depends, Request
from fastapi.responses import JSONResponse
from requests import Session
import requests
from deps import get_db
from dotenv import load_dotenv
import services.llm as llm
from models import AgentConfiguration, BusinessProfile, Template, Workflow


load_dotenv()
# Exotel credentials
EXOTEL_API_KEY = os.getenv("EXOTEL_API_KEY")
EXOTEL_API_TOKEN = os.getenv("EXOTEL_API_TOKEN")
EXOTEL_SUBDOMAIN = os.getenv("EXOTEL_SUBDOMAIN")
EXOTEL_SEND_SMS_URL = os.getenv("EXOTEL_SEND_SMS_URL")


def send_reply_via_exotel_api(from_number, to_number, message):
    """Send WhatsApp message using Exotel API with correct authentication"""
    try:
        payload = {
            "whatsapp": {
                "messages": [{
                    "from": from_number,  # Your Exotel number
                    "to": to_number,      # User's number
                    "content": {
                        "type": "text",
                        "text": {
                            "body": message
                        }
                    }
                }]
            }
        }
        
        # Use basic auth correctly (as shown in Exotel documentation)
        auth = (EXOTEL_API_KEY, EXOTEL_API_TOKEN)
        headers = {"Content-Type": "application/json"}
        
        print(f"[EXOTEL API] Sending reply: {message}")
        print(f"[EXOTEL API] From: {from_number} To: {to_number}")
        print(f"[EXOTEL API] URL: {EXOTEL_SEND_SMS_URL}")
        print(f"[EXOTEL API] Auth Key: {EXOTEL_API_KEY[:5]}... Token: {EXOTEL_API_TOKEN[:5]}...")  # Log first 5 chars for debugging
        
        response = requests.post(EXOTEL_SEND_SMS_URL, json=payload, headers=headers, auth=auth, timeout=30)
        print(f"[EXOTEL API] Response Status: {response.status_code}")
        print(f"[EXOTEL API] Response Body: {response.text}")
        
        if response.status_code not in [200, 201, 202]:
            print(f"[EXOTEL API] Error: {response.text}")
            
    except Exception as e:
        print(f"[EXOTEL API] Failed to send message: {e}")
        import traceback
        traceback.print_exc()

async def send_whatsapp_message(
    to_number: str,
    from_number: str,
    message_type: str,  # 'text', 'image', 'video', 'audio', 'document'
    content: str,       # Text body OR Media URL
    caption: str = None,
    filename: str = None
):
    """
    Unified function to send ANY type of WhatsApp message via Exotel.
    """
    try:
        # 1. Build the specific content object based on type
        msg_content = {}
        
        if message_type == "text":
            msg_content = {
                "type": "text",
                "text": {"body": content}
            }
            
        elif message_type in ["image", "video", "document", "audio"]:
            media_object = {"link": content}
            
            # Audio does not support captions in WhatsApp API
            if message_type != "audio" and caption:
                media_object["caption"] = caption
                
            # Documents support filenames
            if message_type == "document" and filename:
                media_object["filename"] = filename
                
            msg_content = {
                "type": message_type,
                message_type: media_object
            }
        else:
            print(f"[EXOTEL API] Unsupported message type: {message_type}")
            return False

        # 2. Construct the full Exotel payload
        payload = {
            "whatsapp": {
                "messages": [{
                    "from": from_number,
                    "to": to_number,
                    "content": msg_content
                }]
            }
        }

        # 3. Send Request
        auth = (EXOTEL_API_KEY, EXOTEL_API_TOKEN)
        headers = {"Content-Type": "application/json"}
        
        print(f"[EXOTEL API] Sending {message_type} to {to_number}")
        
        response = requests.post(
            EXOTEL_SEND_SMS_URL, 
            json=payload, 
            headers=headers, 
            auth=auth, 
            timeout=30
        )
        
        if response.status_code in [200, 201, 202]:
            return True
        else:
            print(f"[EXOTEL API] Error {response.status_code}: {response.text}")
            return False

    except Exception as e:
        print(f"[EXOTEL API] Exception: {e}")
        return False
    
async def send_chat_state(from_number, to_number, state="typing"):
    """
    Send a chat state (typing indicator) to the user.
    state can be: 'typing' (shows typing...) or 'stop' (stops typing)
    """
    try:
        # This payload structure attempts to map to Meta's "typing_indicator"
        # Note: If Exotel strictly validates 'type', this might need adjustment based on their private docs.
        payload = {
            "whatsapp": {
                "messages": [{
                    "from": from_number,
                    "to": to_number,
                    "content": {
                        # We use the standard Meta type for this
                        "type": "typing_indicator",
                        "typing_indicator": {
                            "type": state  # "typing" or "stop"
                        }
                    }
                }]
            }
        }
        
        auth = (EXOTEL_API_KEY, EXOTEL_API_TOKEN)
        headers = {"Content-Type": "application/json"}
        
        # We use a short timeout (5s) because this is a cosmetic feature; 
        # we don't want to block the main thread if it fails.
        requests.post(EXOTEL_SEND_SMS_URL, json=payload, headers=headers, auth=auth, timeout=5)
        print(f"[EXOTEL API] Sent chat state '{state}' to {to_number}")
            
    except Exception as e:
        # Fail silently for typing indicators so we don't break the main flow
        print(f"[EXOTEL API] Failed to send chat state: {e}")

async def whatsapp_msg_send_api(request: Request):
    try:
        data = await request.json()
        from_number = data.get("from")
        to_number = data.get("to")
        message = data.get("message")
        
        if not all([from_number, to_number, message]):
            return {"status": "error", "message": "Missing required fields"}
        
        send_reply_via_exotel_api(from_number, to_number, message)
        return {"status": "success", "message": "Message sent"}
        
    except Exception as e:
        print(f"[EXOTEL API] Error in whatsapp_msg_send_api: {e}")
        return {"status": "error", "message": str(e)}


def send_reply_via_exotel_api_template(
    to_number: str,
    from_number: str,
    template_name: str,
    params: List[str],
    language: str = "en_US",
    status_callback: Optional[str] = None,
    custom_data: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Send a WhatsApp *template* message via Exotel.
    Docs:
      - Send WhatsApp Template Messages API (endpoint & wrapper) 
      - Sample payload structure (content.template.components)
    """

    try:

        # Build template components: include BODY only if parameters exist
        components = []
        if params:
            components.append({
                "type": "body",
                "parameters": [{"type": "text", "text": str(p)} for p in params]
            })

        payload: Dict[str, Any] = {}
        if custom_data:
            payload["custom_data"] = custom_data
        if status_callback:
            payload["status_callback"] = status_callback

        payload["whatsapp"] = {
            "messages": [
                {
                    "from": from_number,
                    "to": to_number,  # E.164 format
                    "content": {
                        "type": "template",
                        "template": {
                            "name": template_name,
                            "language": {"code": language},
                            "components": components
                        }
                    }
                }
            ]
        }

        # Endpoint per Exotel docs
        headers = {"Content-Type": "application/json"}
        auth = (EXOTEL_API_KEY, EXOTEL_API_TOKEN)

        print(f"[EXOTEL WA] POST {EXOTEL_SEND_SMS_URL}")
        print(f"[EXOTEL WA] To: {to_number} | From: {EXOTEL_SEND_SMS_URL}")
        print(f"[EXOTEL WA] Template: {template_name} | Lang: {language}")
        print(f"[EXOTEL WA] Params: {params}")

        resp = requests.post(EXOTEL_SEND_SMS_URL, json=payload, headers=headers, auth=auth, timeout=30)
        msg = f"""Hi {params[0]}
                  Welcome to {params[1]} !
                  How can I assist you today?
                  """
        #await append_user(to_number,msg)
        print(f"[EXOTEL WA] Status: {resp.status_code}")
        print(f"[EXOTEL WA] Body: {resp.text}")

        if resp.status_code in (200, 201, 202):
            # Exotel returns a per-message code/status inside JSON; bubble it up
            return {"status": "success", "message": "Message request accepted", "response": resp.json()}
        else:
            # Try to surface Exotel's error payload if present
            try:
                return {"status": "error", "message": "API error", "details": resp.json()}
            except Exception:
                return {"status": "error", "message": f"API returned {resp.status_code}", "details": resp.text}

    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"status": "error", "message": f"Exception: {e}"}

async def whatsapp_msg_send_api_via_template(request: Request):
    try:
        data = await request.json()

        to_number = data.get("to")
        from_number = data.get("from")
        template_name = data.get("template","whatsapp_saas_v2")
        params = data.get("params", [])      # Now can be any number of items
        language = data.get("language", "en")  # Optional, defaults to en_US

        # Validate required fields
        if not to_number:
            return JSONResponse(
                status_code=400,
                content={"status": "error", "message": "'to' is required"}
            )
        if not template_name:
            return JSONResponse(
                status_code=400,
                content={"status": "error", "message": "'template' is required"}
            )
        if not isinstance(params, list):
            return JSONResponse(
                status_code=400,
                content={"status": "error", "message": "'params' must be a list"}
            )

        # Send via Exotel
        result = send_reply_via_exotel_api_template(
            to_number=to_number,
            from_number=from_number,
            template_name=template_name,
            params=params,
            language=language
        )

        if result["status"] == "success":
            return {"status": "success", "message": "WhatsApp message sent via template"}
        else:
            return JSONResponse(
                status_code=500,
                content={
                    "status": "error",
                    "message": result.get("message", "Unknown error"),
                    "details": result.get("details", "")
                }
            )

    except Exception as e:
        print(f"[EXOTEL API] Unexpected error in endpoint: {e}")
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": "Internal server error"}
        )
    

async def whatsapp_msg_send_api_bulk(
    tenant_id: int,
    recipients: dict,
    from_number: str = "+919773743558",
    template_name: str = "whatsapp_saas_v3",
    paramsList: list = [],
    language: str = "en" ,
    db: Session = Depends(get_db) ):
    try:


        # tenant_id = data.get("tenant_id") 
        # from_number = data.get("from","+919773743558")  # Optional, for audit/logging
        # recipients = data.get("recipients")
        # template_name = data.get("template", "whatsapp_saas_v2")
        # paramsList = data.get("params", [])
        # language = data.get("language", "en")

        if not isinstance(recipients, list) or len(recipients) == 0:
            return JSONResponse(
                status_code=400,
                content={"status": "error", "message": "'recipients' must be a non-empty list"}
            )
        
        # if not isinstance(paramsList, list):
        #     return JSONResponse(
        #         status_code=400,
        #         content={"status": "error", "message": "'params' must be a list"}
        #     )

        # if not template_name:
        #     return JSONResponse(
        #         status_code=400,
        #         content={"status": "error", "message": "'template' is required"}
        #     )
        template = db.query(Template).filter(Template.tenant_id == tenant_id).first()
        if not template:
            business_profile = db.query(BusinessProfile).filter(BusinessProfile.tenant_id == tenant_id).first()
            if not business_profile:
                return JSONResponse(
                    status_code=400,
                    content={"status": "error", "message": "business profile not found for this tenant"}
                )
            agentconfiguration = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).first()
            if not agentconfiguration:
                return JSONResponse(
                    status_code=400,
                    content={"status": "error", "message": "agent configuration not found for this tenant"}
                )
            wrokflow = db.query(Workflow).filter(Workflow.tenant_id == tenant_id).first()
            if not wrokflow:
                return JSONResponse(
                    status_code=400,
                    content={"status": "error", "message": "workflow not found for this tenant"}
                )
            
            llm_prompt = f"""
                You are an AI assistant helping {business_profile.business_name} (a {business_profile.business_category} business) 
                engage new customers on WhatsApp. Based on the following details:

                - Business Name: {business_profile.business_name}
                - Industry: {business_profile.business_category}
                - Description: {business_profile.description or 'N/A'}
                - Agent Name: {agentconfiguration.agent_name}
                - Agent Tone: {agentconfiguration.conversation_tone or 'friendly and professional'}
                - Workflow Goal: {wrokflow.template or 'initiate a helpful conversation'}

                Generate a short, welcoming WhatsApp message (max 160 characters) that invites the customer to start a conversation.
                The message should feel personal, non-promotional, and encourage a reply (e.g., with a question or clear next step).
                Do not include placeholders like {{name}}—assume it will be sent as plain text.
                i have a approved template body give output for one place holder of template-
                Welcome to <placeholder> !
                  How can I assist you today?
                Return only the message body for placeholder, nothing else.
                """

                # Call your LLM (pseudo-code—replace with actual LLM client)
            generated_body = await llm.analysis(tenant_id,llm_prompt)
            paramsList.insert(0,generated_body.strip())
            # Save the generated body into the Template model
            new_template = Template(
                    tenant_id=tenant_id,
                    body=generated_body.strip(),
                    name="whatsapp_saas_v2",
                    language="en",
                    status= "active"    # or whatever enum/type you use
                )
            db.add(new_template)
            db.commit()   
            
        else:
            paramsList.insert(0,template.body)
            
        for idx, recipient in enumerate(recipients):
            if not isinstance(recipient, dict):
                return JSONResponse(
                    status_code=400,
                    content={"status": "error", "message": f"Recipient at index {idx} is not a valid object"}
                )
            if not recipient.get("to"):
                return JSONResponse(
                    status_code=400,
                    content={"status": "error", "message": f"Recipient at index {idx} missing 'to' field"}
                )
            

        results = []
        success_count = 0
        failure_count = 0

        for recipient in recipients:
            to_number = recipient["to"]
            name = recipient.get("name") or "Sir/Madam"
            full_params = [name] + paramsList

            result = send_reply_via_exotel_api_template(
                to_number=to_number,
                from_number=from_number,
                template_name=template_name,
                params=full_params,
                language=language
            )

            results.append({
                "to": to_number,
                "name": name,
                "result": result
            })

            if result["status"] == "success":
                success_count += 1
            else:
                failure_count += 1

        return {
            "status": "completed",
            "total_sent": len(recipients),
            "success_count": success_count,
            "failure_count": failure_count,
            "from": from_number,
            "results": results
        }

    except Exception as e:
        print(f"[EXOTEL API] Unexpected error in bulk endpoint: {e}")
        import traceback
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": "Internal server error"}
        )
    
def send_template_with_media(
    to_number: str,
    from_number: str,
    template_name: str,
    media_url: str,
    body_params: List[str],  # List of strings for {{1}}, {{2}}, etc.
    language: str = "en",
    media_type: str = "image" # 'image', 'video', or 'document'
):
    """
    Send a WhatsApp template message that includes a Media Header and Body Parameters.
    """
    try:
        # 1. Construct Components
        components = []

        # --- Header Component (Media) ---
        if media_url:
            components.append({
                "type": "header",
                "parameters": [
                    {
                        "type": media_type,
                        media_type: {
                            "link": media_url
                        }
                    }
                ]
            })

        # --- Body Component (Text Placeholders) ---
        if body_params:
            # Convert all params to text parameters
            parameters = [{"type": "text", "text": str(p)} for p in body_params]
            components.append({
                "type": "body",
                "parameters": parameters
            })

        # 2. Construct Payload
        payload = {
            "whatsapp": {
                "messages": [{
                    "from": from_number,
                    "to": to_number,
                    "content": {
                        "type": "template",
                        "template": {
                            "name": template_name,
                            "language": {"code": language},
                            "components": components
                        }
                    }
                }]
            }
        }

        # 3. Send Request
        auth = (EXOTEL_API_KEY, EXOTEL_API_TOKEN)
        headers = {"Content-Type": "application/json"}
        
        print(f"[EXOTEL API] Sending Template: {template_name} to {to_number}")
        print(f"[EXOTEL API] Media: {media_url}")
        print(f"[EXOTEL API] Body Params: {body_params}")

        response = requests.post(
            EXOTEL_SEND_SMS_URL, 
            json=payload, 
            headers=headers, 
            auth=auth, 
            timeout=30
        )

        print(f"[EXOTEL API] Response: {response.status_code} - {response.text}")
        return response.status_code in [200, 201, 202]

    except Exception as e:
        print(f"[EXOTEL API] Error sending template: {e}")
        import traceback
        traceback.print_exc()
        return False