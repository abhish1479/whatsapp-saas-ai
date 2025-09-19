import os, asyncio, logging
from datetime import timedelta
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

logging.basicConfig(level=logging.INFO)

DB_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://wa_user:wa_pass@localhost:5432/wa_saas")
engine = create_async_engine(DB_URL, echo=False)
SessionLocal = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)

EXPIRY_HOURS = int(os.getenv("CONVERSATION_EXPIRY_HOURS", "24"))

async def expire_conversations():
    async with SessionLocal() as session:
        result = await session.execute(
            text("""
                UPDATE conversations
                SET status='closed', last_message_at=now()
                WHERE status='open'
                  AND last_message_at < (now() - interval :hrs)
                RETURNING id
            """),
            {"hrs": f"{EXPIRY_HOURS} hours"},
        )
        closed = result.fetchall()
        if closed:
            logging.info(f"[Conversations] Auto-closed {len(closed)} conversations")
        await session.commit()

async def main():
    while True:
        await expire_conversations()
        await asyncio.sleep(3600)  # run every hour

if __name__ == "__main__":
    asyncio.run(main())
