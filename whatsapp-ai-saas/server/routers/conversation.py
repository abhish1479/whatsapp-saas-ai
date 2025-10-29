from fastapi import APIRouter, Depends, HTTPException, Request
from requests import Session
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from deps import get_db
from services.exotel_api import whatsapp_msg_send_api_bulk
from services import llm

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