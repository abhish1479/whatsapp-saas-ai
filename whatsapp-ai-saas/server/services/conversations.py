import logging
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

logger = logging.getLogger(__name__)


async def get_active_conversation(session: AsyncSession, tenant_id: str, user_number: str) -> Optional[str]:
    """
    Returns the active conversation ID for a given user in a tenant, or None if none exists.
    """
    q = await session.execute(
        text("""
        SELECT id FROM conversations
        WHERE tenant_id = :t AND user_number = :u AND status = 'open'
        ORDER BY last_message_at DESC
        LIMIT 1
        """),
        {"t": tenant_id, "u": user_number},
    )
    row = q.first()
    return row[0] if row else None


async def open_conversation(session: AsyncSession, tenant_id: str, user_number: str) -> str:
    """
    Opens a new conversation (or reuses active one if exists).
    Returns conversation ID.
    """
    existing = await get_active_conversation(session, tenant_id, user_number)
    if existing:
        logger.info(f"[Conversations] Reusing active conversation {existing} for {user_number}")
        return existing

    q = await session.execute(
        text("""
        INSERT INTO conversations (tenant_id, user_number, status, last_message_at)
        VALUES (:t, :u, 'open', now())
        RETURNING id
        """),
        {"t": tenant_id, "u": user_number},
    )
    row = q.first()
    await session.commit()
    cid = row[0]
    logger.info(f"[Conversations] Opened new conversation {cid} for {user_number}")
    return cid


async def close_conversation(session: AsyncSession, conversation_id: str):
    """
    Closes a conversation (sets status=closed).
    """
    await session.execute(
        text("UPDATE conversations SET status='closed', last_message_at=now() WHERE id=:cid"),
        {"cid": conversation_id},
    )
    await session.commit()
    logger.info(f"[Conversations] Closed conversation {conversation_id}")


async def update_conversation_timestamp(session: AsyncSession, conversation_id: str):
    """
    Refresh last_message_at timestamp (on each inbound/outbound).
    """
    await session.execute(
        text("UPDATE conversations SET last_message_at=now() WHERE id=:cid"),
        {"cid": conversation_id},
    )
    await session.commit()
