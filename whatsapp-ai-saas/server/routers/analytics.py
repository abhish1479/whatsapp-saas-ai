from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from ..deps import get_db

router = APIRouter(prefix="/analytics", tags=["analytics"])

@router.get("/moderation-logs")
async def get_moderation_logs(limit: int = 100, db: AsyncSession = Depends(get_db)):
    rows = await db.execute(text("SELECT * FROM moderation_logs ORDER BY created_at DESC LIMIT :lim"), {"lim": limit})
    return {"logs": [dict(r) for r in rows.mappings().all()]}
