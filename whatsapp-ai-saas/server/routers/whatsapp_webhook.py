from fastapi import Request
from fastapi.responses import Response
from services.ai_model import process_message_background
import asyncio
from fastapi import Request
from fastapi.responses import Response

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



