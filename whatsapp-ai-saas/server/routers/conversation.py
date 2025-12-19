from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel
from requests import Session
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from deps import get_db
from services.exotel_api import whatsapp_msg_send_api_bulk , send_whatsapp_message ,send_chat_state , send_reply_via_exotel_api ,send_template_with_media
from services import llm
from data_models.request_model import TemplateSendRequest
from fastapi.responses import JSONResponse
from utils.sessions import get_history , append_assistant , append_user
from services.ai_model import intelligence_model


router = APIRouter(tags=["conversations"])


@router.get("/{conversation_id}")
async def get_conversation(conversation_id: str, db: AsyncSession = Depends(get_db)):
    sql = text("SELECT * FROM conversations WHERE id=:id")
    row = await db.execute(sql, {"id": conversation_id})
    convo = row.mappings().first()
    if not convo:
        raise HTTPException(404, "Conversation not found")
    msgs = await db.execute(text("SELECT * FROM messages WHERE conversation_id=:id ORDER BY created_at ASC"), {"id": conversation_id})
    return {"conversation": dict(convo), "messages": [dict(m) for m in msgs.mappings().all()]}

@router.get("/{conversation_id}/summary")
async def get_summary(conversation_id: str, db: AsyncSession = Depends(get_db)):
    row = await db.execute(text("SELECT summary FROM conversations WHERE id=:id"), {"id": conversation_id})
    convo = row.first()
    if not convo:
        raise HTTPException(404, "Conversation not found")
    return {"conversation_id": conversation_id, "summary": convo[0]}


@router.post("/talk_to_me")
async def template_msg_send(
    request_data: TemplateSendRequest,
    db: Session = Depends(get_db)
):
    try:
        # Convert recipients to list of dicts (Pydantic already validates structure)
        recipients = [r.dict() for r in request_data.recipients]

        result = await whatsapp_msg_send_api_bulk(
            db=db,
            tenant_id=request_data.tenant_id,
            recipients=recipients,
            from_number="+919773743558",
            template_name="whatsapp_saas_v3",
            paramsList=[],  # no extra params beyond name + body
            language="en"
        )
        return result

    except ValueError as ve:
        return JSONResponse(
            status_code=400,
            content={"status": "error", "message": str(ve)}
        )
    except Exception as e:
        print(f"[TALK_TO_ME] Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": "Internal server error"}
        )


@router.post("/workflow_optimizer")
async def workflow_optimizer(
    tenant_id: int ,
    query: str = None,
):
    query_prompt = f"""
            You are a WhatsApp AI workflow optimizer. Given the owner's goal: "{query or 'general assistance'}", create a minimal, practical conversation flow for a WhatsApp agent.

            Rules:
            - Use plain text and next line — no markdown, no headings, no bullet symbols.
            - Keep every message under 15 words.
            - Ask at most few short qualifying questions if owner specify in gole.
            - Use simple "if-then" logic (e.g., "If X, say Y").
            - End with one clear closing or handoff line.

            Output format:
            Start: [opening message]
            optional second question if any needed
            If [condition]: [reply]
            If [condition]: [reply]
            ...
            End: [final message or handoff]
            """
    return await llm.analysis(tenant_id, query_prompt)


@router.post("/test_agent")
async def test_agent(
    query: str,
    tenant_id: int,
    phone_number: str = None,
):
    if phone_number is None:
        phone_number = str(tenant_id)
    get_conversation = get_history(sender = phone_number, tenant_id=tenant_id)
    await append_user(sender= phone_number, content=query)
   #get_conversation = get_history(sender = str(phone_number), tenant_id=tenant_id)
   #model_reply = await llm.llm_model_reply(tenant_id,get_conversation)
    model_reply = await intelligence_model(phone_number,tenant_id)
   #append_assistant(sender=str(phone_number), content=model_reply)
    return {"reply": model_reply}


@router.post("/msg_send")
async def msg_send(
    to_number: str,
    from_number: str,
    message_type: str,
    content: str,       
    caption: str = None,
    filename: str = None
):

    try:
        res = await send_whatsapp_message(
            to_number=to_number,
            from_number=from_number,
            message_type=message_type,
            content = content,       
            caption = caption,
            filename = filename
        )
        return {"status": {res}, "message": "Message sent successfully"}
    except Exception as e:
        print(f"[MSG_SEND] Error sending message: {e}")
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": "Failed to send message"}
        )
    
@router.post("/chat_state")
async def chat_state( 
    to_number: str,
    from_number: str,
    chat_state: str
  ):
    try:
        res = await send_chat_state(
            to_number=to_number,
            from_number=from_number,
            state=chat_state
        )
        return {"status": {res}, "message": "Chat state sent successfully"}
    except Exception as e:
        print(f"[CHAT_STATE] Error sending chat state: {e}")
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": "Failed to send chat state"}
        )
    
@router.post("/reply_via_exotel")
async def reply_via_exotel_api( 
    to_number: str,
    from_number: str,
    message: str,
  ):
    try:
        res = await send_reply_via_exotel_api(
            to_number=to_number,
            from_number=from_number,
            message=message,
        )
        return {"status": {res}, "message": "Reply sent successfully via Exotel"}
    except Exception as e:
        print(f"[REPLY_VIA_EXOTEL] Error sending reply via Exotel: {e}")
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": "Failed to send reply via Exotel"}
        )
    
class AdmissionInquiryRequest(BaseModel):
    to_number: str
    tenant_id: int # To fetch correct config/sender if needed, or pass sender manually
    # Body variables matching your template: {{1}}, {{2}}, {{3}}, {{4}}
    student_name: str       # {{1}} e.g. "Azim"
    course_name: str        # {{2}} e.g. "NEET/JEE"
    center_name: str        # {{3}} e.g. "ALLEN"
    session_year: str       # {{4}} e.g. "2025-26"
    # Header media
    image_url: str          # URL for the banner image

@router.post("/send_admission_inquiry")
async def send_admission_inquiry(request: AdmissionInquiryRequest):
    """
    Sends the 'addmission_inquiry' template with an image header and 4 body variables.
    """
    # Hardcoded sender for now, or fetch from DB based on tenant_id
    from_number = "919773743558" 
    
    # Template specific config
    TEMPLATE_NAME = "addmission_inquiry"
    
    # Prepare body parameters in correct order: {{1}}, {{2}}, {{3}}, {{4}}
    body_params = [
        request.student_name,  
        request.course_name,   
        request.center_name,   
        request.session_year   
    ]

    success = send_template_with_media(
        to_number=request.to_number,
        from_number=from_number,
        template_name=TEMPLATE_NAME,
        media_url=request.image_url,
        body_params=body_params,
        language="en"
    )

    if success:
        return {"status": "success", "message": "Admission inquiry sent successfully"}
    else:
        return JSONResponse(status_code=500, content={"status": "error", "message": "Failed to send message via Exotel"})
