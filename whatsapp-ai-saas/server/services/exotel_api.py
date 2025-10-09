import os
from typing import Any, Dict, List, Optional
from fastapi import Depends, Request
from fastapi.responses import JSONResponse
from requests import Session
import requests
from deps import get_db
from dotenv import load_dotenv
from models import BusinessProfile


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
        msg = f"""Hi {params[0]}, this is {params[1]}!
                We’re offering {params[2]} — exclusively for you.
                    -Limited slots/time
                    -No obligation
                    - Instant benefit
            Are you available to learn more or get started today? Reply YES or NO."""
        #append_user(to_number,msg)
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
        template_name = data.get("template","whatsapp_saas")
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
    

async def whatsapp_msg_send_api_bulk(request: Request,
    db: Session = Depends(get_db)                                 
                                     ):
    try:
        data = await request.json()

        tenant_id = data.get("tenant_id") 
        from_number = data.get("from","+919773743558")  # Optional, for audit/logging
        recipients = data.get("recipients")
        template_name = data.get("template", "whatsapp_saas")
        paramsList = data.get("params", [])
        language = data.get("language", "en")

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
        
        business_profile = db.query(BusinessProfile).filter(BusinessProfile.tenant_id == tenant_id).first()
        if not business_profile:
            return JSONResponse(
                status_code=400,
                content={"status": "error", "message": "business profile not found for this tenant"}
            )
        paramsList.insert(0,business_profile.business_category)
        paramsList.insert(1,business_profile.custom_business_type)

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