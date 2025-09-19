import os, asyncio, logging
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
import httpx

logging.basicConfig(level=logging.INFO)

DB_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost:5432/app")
LLM_ENDPOINT = os.getenv("LLM_SUMMARY_URL", "http://localhost:8001/summarize")

engine = create_async_engine(DB_URL, echo=False)
SessionLocal = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)

async def fetch_open_conversations(session):
    sql = text("SELECT id FROM conversations WHERE status='open'")
    res = await session.execute(sql)
    return [r[0] for r in res]

async def summarize_conversation(session, convo_id):
    msgs = await session.execute(text("SELECT sender, body FROM messages WHERE conversation_id=:id ORDER BY created_at ASC"), {"id": convo_id})
    text_content = "\n".join([f"{m[0]}: {m[1]}" for m in msgs if m[1]])
    if not text_content.strip():
        return
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(LLM_ENDPOINT, json={"text": text_content})
        if resp.status_code == 200:
            summary = resp.json().get("summary")
            await session.execute(text("UPDATE conversations SET summary=:s, updated_at=now() WHERE id=:id"), {"s": summary, "id": convo_id})

async def main():
    while True:
        async with SessionLocal() as session:
            convos = await fetch_open_conversations(session)
            for cid in convos:
                await summarize_conversation(session, cid)
            await session.commit()
        await asyncio.sleep(60)

if __name__ == "__main__":
    asyncio.run(main())
