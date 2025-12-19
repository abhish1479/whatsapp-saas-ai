import asyncio
import json
import re
from fastapi.responses import Response
from typing import Optional
from services.rag import rag
from services.llm import client
from utils.gpt_helpers import extract_gpt_reply
from utils.sessions import get_history, append_user, append_assistant
# LLM tool schema (LLM decides when to call)
from utils.tool_schemas import TOOLS
# External API call with hardcoded brandName
# from app.services.tickets import (get_all_tickets, get_ticket_details, get_ticket_status_external, create_ticket_external)
from services.exotel_api import send_reply_via_exotel_api
from services.process_media import process_media_message
#from utils.log import append_media_log, append_usage
from routers.onboarding import get_tanant_id_from_receiver


async def process_message_background(sender, receiver, user_input, content):
    """Process the message in the background and send reply via Exotel API"""
    try:
        print(f"[BACKGROUND] Processing message from {sender}: {user_input}")
        
        # Your existing message processing logic here
        # Ensure session exists / not expired
        tenant_id = get_tanant_id_from_receiver(receiver)
        get_history(sender,tenant_id)
        
        # Handle media content if needed
        content_type = content.get('type', '')
        if content_type in ['image', 'audio']:
            # Extract media URL and process accordingly
            media_url = None
            if content_type == 'image':
                image_data = content.get('image', {})
                media_url = image_data.get('url', '') or image_data.get('link', '')
                #asyncio.create_task(append_media_log(sender, media_url, content_type))
            elif content_type == 'audio':
                audio_data = content.get('audio', {})
                media_url = audio_data.get('url', '') or audio_data.get('link', '')
                #asyncio.create_task(append_media_log(sender, media_url, content_type))

            if media_url:
                await process_media_message(sender, content_type, media_url, user_input)
            else:
                await append_user(sender, user_input or "Hi")
        else:
            await append_user(sender, user_input or "Hi")

        # Call intelligence model to get AI response
        ai_reply = await intelligence_model(sender,tenant_id)
        send_reply_via_exotel_api(receiver, sender, ai_reply)
        return Response(content='', media_type="text/plain", status_code=200)
        
    except Exception as e:
        print(f"[BACKGROUND] Processing error: {e}")
        import traceback
        traceback.print_exc()
        # Send error message
        error_reply = "⚠️ Sorry, I'm having trouble responding right now."
        # send_reply_via_exotel_api(receiver, sender, error_reply)
        return Response(content='', media_type="text/plain", status_code=200)

# async def process_message(usrr_role , sender, query, image_bytes: Optional[bytes] = None, audio_bytes: Optional[bytes] = None,ticketId: Optional[str] = None):
#     """Process the message and return AI reply"""
#     try:
#         print(f"[SYNC] Processing message from {sender}: {query}")
        
#         get_history(sender)
        
#         if ticketId:
#             res = get_contant_details(ticketId, contant_type="Ticket",fetcher=get_ticket_details )
#             await append_user(sender, json.dumps(res, ensure_ascii=False))
#         # Handle media content if needed
#         if image_bytes or audio_bytes:
#             await process_media_files(sender, query, image_bytes=image_bytes, audio_bytes=audio_bytes)
        
#         if query:
#           await append_user(sender, query or "Hi")

#         # Call intelligence model to get AI response
#         ai_reply = await intelligence_model_tech(sender)
#         return ai_reply
        
#     except Exception as e:
#         print(f"[SYNC] Processing error: {e}")
#         import traceback
#         traceback.print_exc()
#         # Send error message
#         error_reply = "⚠️ Sorry, I'm having trouble responding right now."
#         return error_reply


async def intelligence_model(sender,tenant_id):
    try:
        decision =await client.chat.completions.create(
            model="gpt-4o",
            temperature=0.2,
            tools=TOOLS,
            tool_choice="auto",
            messages=get_history(sender,tenant_id),
        )

        choice = decision.choices[0]
        tool_calls = getattr(choice.message, "tool_calls", None)
        usage = getattr(decision, "usage", None)
        #asyncio.create_task(append_usage(sender, usage.total_tokens, "token"))
        if tool_calls:
            tool_msgs = []
            for tc in tool_calls:
                name = tc.function.name
                args = json.loads(tc.function.arguments or "{}")

                # derive phone number from WhatsApp sender (digits only)
                phone_number = re.sub(r"\D", "", sender) if sender else ""
                phone_number = phone_number[-10:] if len(phone_number) >= 10 else phone_number
                
                if name == "find_rag_info":
                    query = args.get("query")
                    print(f"[RAG TOOL] Query: {query}")
                    if not query:
                        ai_reply = extract_gpt_reply(choice) or (
                                "I can help you with your query. Could you tell me more?"
                            )
                        append_assistant(sender, ai_reply)
                        return ai_reply

                    # Call your external API
                    rag_context = ""
                    result = await rag.search(tenant_id=tenant_id, query=query, k=4)
                    if result:
                        snippets = [
                                f"• {r['text']}" for r in result[:4]
                            ]
                        rag_context = "\n".join(snippets)
                    get_history(sender,tenant_id).append({"role": "system", "content": rag_context})  
                    tool_msgs.append({
                        "role": "tool",
                        "tool_call_id": tc.id,
                        "name": name,
                        "content": json.dumps(result)
                    })      
                else:
                    tool_msgs.append({
                        "role": "tool",
                        "tool_call_id": tc.id,
                        "name": name,
                        "content": json.dumps({"error": "unknown_tool"})
                    })
                    
            # Refinement pass
            refined =await client.chat.completions.create(
                model="gpt-4o",
                temperature=0.2,
                messages=get_history(sender) + [choice.message] + tool_msgs + [{
                    "role": "system",
                    "content": "Rewrite the tool results for the end user in the same language/style they used also add new line in proper formate,Use *single asterisk* for bold.Use relevant emojis in your responses to improve readability"
                }],
            )
            usage = getattr(refined, "usage", None)
            # asyncio.create_task(append_usage(sender, usage.total_tokens, "token"))
            print(f"[BACKGROUND] Refinement usage: {usage.total_tokens}")
            ai_reply = extract_gpt_reply(refined.choices[0])
        else:
            # No tool call: just use the model's text reply
            ai_reply = extract_gpt_reply(choice) or (
                "I can help you with your query. Could you tell me more?"
            )

        # Save assistant reply to history
        append_assistant(sender, ai_reply)
        print(f"[BACKGROUND] AI Reply: {ai_reply!r}")
        return ai_reply
        
    except Exception as e:
        print(f"[BACKGROUND] Processing error: {e}")
        import traceback
        traceback.print_exc()
        # Send error message
        error_reply = "⚠️ Sorry, I'm having trouble responding right now."
        return error_reply
    

# async def intelligence_model_tech(sender):
#     try:
#         decision = client.chat.completions.create(
#             model="gpt-4o",
#             temperature=0.2,
#             messages=get_history(sender),
#         )

#         choice = decision.choices[0]
#         #tool_calls = getattr(choice.message, "tool_calls", None)

#         # if tool_calls:
#         #     tool_msgs = []
#         #     for tc in tool_calls:
#         #         name = tc.function.name
#         #         args = json.loads(tc.function.arguments or "{}")

#         #         # derive phone number from WhatsApp sender (digits only)
#         #         phone_number = re.sub(r"\D", "", sender) if sender else ""
#         #         phone_number = phone_number[-10:] if len(phone_number) >= 10 else phone_number

                    
#         #     # Refinement pass
#         #     refined = client.chat.completions.create(
#         #         model="gpt-4o",
#         #         temperature=0.2,
#         #         messages=get_history(sender) + [choice.message] + tool_msgs + [{
#         #             "role": "system",
#         #             "content": "Rewrite the tool results for the end user in the same language/style they used also add new line in proper formate,Use *single asterisk* for bold.Use relevant emojis in your responses to improve readability.Summarize clearly: ticket_id, status, any assignee/ETA/last_update if present. for tool `get_all_tickets` alos show ticket_summary, for create_ticket only check MobiForceTicketId if null or empty then ticket creation failed else success."
#         #         }],
#         #     )
#         #     ai_reply = extract_gpt_reply(refined.choices[0])
#         # else:
#         #     # No tool call: just use the model's text reply
#         #     ai_reply = extract_gpt_reply(choice) or (
#         #         "I can help you with appliance troubleshooting. Could you tell me more about the problem?"
#         #     )

#         ai_reply = extract_gpt_reply(choice)
#         # Save assistant reply to history
#         append_assistant(sender, ai_reply)
#         print(f"[BACKGROUND] AI Reply: {ai_reply!r}")
#         return ai_reply
        
#     except Exception as e:
#         print(f"[BACKGROUND] Processing error: {e}")
#         import traceback
#         traceback.print_exc()
#         # Send error message
#         error_reply = "⚠️ Sorry, I'm having trouble responding right now."
#         return error_reply