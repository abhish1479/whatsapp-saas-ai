from fastapi import APIRouter, Depends, HTTPException, Request
from requests import Session
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from deps import get_db
from services.exotel_api import whatsapp_msg_send_api_bulk
from services import llm

router = APIRouter(prefix="/conversations", tags=["conversations"])

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
async def talk_to_me(
    request: Request,
    db: Session = Depends(get_db)
):
    return await whatsapp_msg_send_api_bulk(request, db)


@router.post("/workflow_optimizer")
async def workflow_optimizer(
    tenant_id: int ,
    query: str = None,
):
    query_prompt = query_prompt = f"""
            You are an expert conversational workflow designer for WhatsApp-based AI agents. Your goal is to create a highly effective, human-like, and conversion-optimized dialogue flow tailored to the business context.

            Given the owner's intent: "{query or 'No specific query provided'}", design a step-by-step WhatsApp agent workflow that:

            1. **Initiates the conversation** in a warm, non-intrusive, and value-driven way (e.g., personalized greeting referencing user context if available).
            2. **Identifies user intent early** by asking 1–2 smart, open-ended but focused qualifying questions.
            3. **Adapts dynamically** based on user responses—route to onboarding, support, sales, or information delivery as needed.
            4. **Minimizes friction**: use short messages, buttons (if supported), and clear next steps.
            5. **Drives toward a clear goal** (e.g., booking a demo, answering FAQs, collecting lead info, or completing onboarding).
            6. **Handles objections or silence gracefully** with fallback messages or gentle nudges.
            7. **Maintains brand tone**—professional yet friendly, concise, and helpful.

            Output only the optimized workflow as a structured plan with:
            - Opening message
            - Key qualifying questions (max 2–3)
            - Decision logic (e.g., “If user mentions pricing → share plans + CTA”)
            - Closing or handoff strategy (e.g., to human agent or confirmation)

            Do not include explanations—just the workflow.
            """
    return await llm.analysis(tenant_id, query_prompt)