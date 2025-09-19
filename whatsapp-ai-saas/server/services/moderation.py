# server/services/moderation.py

from typing import Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from server.services.metrics import moderation_blocks


async def moderate_message(
    tenant_id: str,
    message: str,
    db: AsyncSession,
    conversation_id: str | None = None,
    message_id: str | None = None,
) -> Dict[str, Any]:
    """
    Run moderation on a message.
    - tenant_id: tenant who owns the conversation
    - message: text body to check
    - db: async DB session (for logging moderation events)
    - conversation_id: optional conversation reference
    - message_id: optional message reference

    Returns dict:
      { "allowed": bool, "risk_score": float, "reason": str | None }
    """

    flagged = False
    reason = None
    risk_score = 0.0

    # === Replace this with actual moderation provider call (OpenAI, Perspective, etc.) ===
    if "forbidden" in message.lower():
        flagged = True
        reason = "Contains forbidden word"
        risk_score = 0.9

    # === If flagged, update metrics + DB ===
    if flagged:
        # Prometheus counter
        moderation_blocks.labels(tenant_id=tenant_id).inc()

        # Insert into moderation_logs table
        await db.execute(
            text(
                """
                INSERT INTO moderation_logs (tenant_id, conversation_id, message_id, reason, risk_score)
                VALUES (:t, :c, :m, :r, :s)
                """
            ),
            {
                "t": tenant_id,
                "c": conversation_id,
                "m": message_id,
                "r": reason,
                "s": risk_score,
            },
        )

        return {"allowed": False, "reason": reason, "risk_score": risk_score}

    # === Not flagged ===
    return {"allowed": True, "risk_score": risk_score}
