import asyncio
from datetime import time
import httpx
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
from sqlalchemy import text
from sqlalchemy.orm import Session
from deps import get_db
from services import rag, llm
from models import BusinessCatalog
import logging
from services.rag import rag

logger = logging.getLogger(__name__)

CRAWL_LIMIT = 50  # max pages per request
LLM_BATCH_SIZE = 2000  # chars per chunk for LLM parsing

async def fetch_html(url: str) -> str:
    async with httpx.AsyncClient(timeout=20) as client:
        resp = await client.get(url)
        resp.raise_for_status()
        return resp.text

def extract_links(base_url: str, html: str) -> list[str]:
    soup = BeautifulSoup(html, "html.parser")
    links = []
    for tag in soup.find_all("a", href=True):
        link = urljoin(base_url, tag["href"])
        # restrict to same domain
        if urlparse(link).netloc == urlparse(base_url).netloc:
            links.append(link)
    return links

def clean_text(html: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    for tag in soup(["script", "style", "noscript"]):
        tag.decompose()
    return soup.get_text(" ", strip=True)

def extract_images(base_url: str, html: str) -> list[str]:
    soup = BeautifulSoup(html, "html.parser")
    image_urls = []
    for img in soup.find_all("img", src=True):
        url = urljoin(base_url, img["src"])
        image_urls.append(url)
    return image_urls

async def parse_structured_with_llm(text: str, source_url: str) -> list[dict]:
    """
    Ask LLM to return structured catalog items (generic schema).
    """
    prompt = f"""
    Extract business items from the following text. Items may be products, services, rooms, courses, packages.
    Return as JSON list with fields:
    item_type, name, description, category, price, discount, currency, source_url.
    Text:
    {text[:LLM_BATCH_SIZE]}
    """
    try:
        response = await llm.generate_reply(prompt)  # assume llm.call returns JSON
        items = response if isinstance(response, list) else []
        for item in items:
            item["source_url"] = source_url
        return items
    except Exception as e:
        logger.error(f"LLM parsing failed for {source_url}: {e}")
        return []

async def crawl_and_ingest(session: Session, tenant_id: str, start_url: str):
    visited, to_visit = set(), [start_url]
    pages_processed = 0
    print(f"Starting crawl for tenant {tenant_id} from {start_url}")
    while to_visit and pages_processed < CRAWL_LIMIT:
        url = to_visit.pop()
        if url in visited:
            continue
        try:
            html = await fetch_html(url)
            print(f"Fetched {url} ({len(html)} bytes)")
            text = clean_text(html)
            print(f"Fetched {url} with {len(text)} chars")
            # Step A: Add to RAG
            await rag.add_documents(tenant_id, [{"text": text, "source_url": url}])
            # Step B: Parse structured catalog via LLM
            items = await parse_structured_with_llm(text, url)
            # also extract images from page
            image_urls = extract_images(url, html)

            for idx, item in enumerate(items):
                catalog_entry = BusinessCatalog(
                    tenant_id=tenant_id,
                    item_type=item.get("item_type", "other"),
                    name=item.get("name"),
                    description=item.get("description"),
                    category=item.get("category"),
                    price=item.get("price"),
                    discount=item.get("discount"),
                    currency=item.get("currency"),
                    source_url=item.get("source_url"),
                    image_url=image_urls[idx] if idx < len(image_urls) else None
                )
                session.add(catalog_entry)

            # Find more links
            for link in extract_links(url, html):
                if link not in visited:
                    to_visit.append(link)

            visited.add(url)
            pages_processed += 1
            session.commit()

        except Exception as e:
            logger.error(f"Error processing {url}: {e}")
            session.rollback()

def background_crawl(tenant_id: int, url: str):
    """Sync function called in background"""
    db_gen = get_db()
    session = next(db_gen)
    try:
        # Mark as processing
        print(f"🚀 Starting crawl for tenant {tenant_id} at {url}")
        session.execute(
            text("UPDATE web_ingest_requests SET status = 'processing' WHERE tenant_id = :t AND url = :u"),
            {"t": tenant_id, "u": url}
        )
        session.commit()

        # Do the crawl
        asyncio.run(crawl_and_ingest(session, str(tenant_id), url))

        # Mark as done
        print(f"✅ Completed crawl for tenant {tenant_id} at {url}")
        session.execute(
            text("UPDATE web_ingest_requests SET status = 'done' WHERE tenant_id = :t AND url = :u"),
            {"t": tenant_id, "u": url}
        )
        session.commit()
    except Exception as e:
        logger.exception("Crawl failed")
        session.rollback()
        session.execute(
            text("UPDATE web_ingest_requests SET status = 'error' WHERE tenant_id = :t AND url = :u"),
            {"t": tenant_id, "u": url}
        )
        session.commit()
    finally:
        db_gen.close()

def main():
    while True:
        db_gen = get_db()
        session = next(db_gen)  # Get the session from the generator
        try:
            print("🔍 Checking for queued ingest requests...")
            result = session.execute(
                text("SELECT id, tenant_id, url FROM web_ingest_requests WHERE status = 'queued' LIMIT 5")
            )
            rows = result.fetchall()

            for row in rows:
                try:
                    crawl_and_ingest(session, str(row.tenant_id), row.url)
                    session.execute(
                        text("UPDATE web_ingest_requests SET status = 'done' WHERE id = :id"),
                        {"id": row.id}
                    )
                    session.commit()
                    print(f"✅ Completed request {row.id}")
                except Exception as e:
                    logger.exception(f"❌ Failed request {row.id}: {e}")
                    session.rollback()
                    session.execute(
                        text("UPDATE web_ingest_requests SET status = 'error' WHERE id = :id"),
                        {"id": row.id}
                    )
                    session.commit()

        except Exception as e:
            logger.critical(f"💥 Fatal error in main loop: {e}")
        finally:
            # Ensure the generator is closed (triggers db.close())
            db_gen.close()

        print("😴 Sleeping for 30 seconds...")
        time.sleep(30)

if __name__ == "__main__":
    main()