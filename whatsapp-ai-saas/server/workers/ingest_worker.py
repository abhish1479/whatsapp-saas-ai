# server/workers/ingest_worker.py
import os, asyncio, logging, httpx
from bs4 import BeautifulSoup
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
from server.services.rag import rag

logging.basicConfig(level=logging.INFO)

DB_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost:5432/app")

engine = create_async_engine(DB_URL, echo=False)
SessionLocal = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)

async def fetch_html(url: str) -> str:
    async with httpx.AsyncClient(timeout=20) as client:
        r = await client.get(url)
        return r.text

def extract_text(html: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    # Remove script/style
    for s in soup(["script","style","noscript"]): s.extract()
    text = soup.get_text(separator=" ")
    return " ".join(text.split())

async def process_request(session: AsyncSession, row):
    id, tenant_id, url = row
    try:
        html = await fetch_html(url)
        txt = extract_text(html)
        docs = [{"id": url, "text": txt, "source_url": url, "version": "v1", "language": "en"}]
        await rag.add_documents(tenant_id, docs)
        await session.execute(text("UPDATE web_ingest_requests SET status='done' WHERE id=:id"), {"id": id})
        logging.info(f"Ingested website for tenant={tenant_id} url={url}")
    except Exception as e:
        await session.execute(text("UPDATE web_ingest_requests SET status='error' WHERE id=:id"), {"id": id})
        logging.exception(f"Failed ingest tenant={tenant_id} url={url}: {e}")

async def main():
    while True:
        async with SessionLocal() as session:
            rows = (await session.execute(text("SELECT id, tenant_id, url FROM web_ingest_requests WHERE status='queued' LIMIT 5"))).fetchall()
            for row in rows:
                await process_request(session, row)
            await session.commit()
        await asyncio.sleep(30)

if __name__ == "__main__":
    asyncio.run(main())
