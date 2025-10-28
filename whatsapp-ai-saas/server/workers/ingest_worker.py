import asyncio
from datetime import time
import json
from typing import List
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
from playwright.async_api import async_playwright


logger = logging.getLogger(__name__)

CRAWL_LIMIT = 100  # max pages per request
LLM_BATCH_SIZE = 2000  # chars per chunk for LLM parsing
CATALOG_LIMIT = 30  # max items to ingest per request

async def fetch_html(url: str) -> str:
    async with async_playwright() as p:
        browser = await p.chromium.launch(
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
                "--disable-gpu",
            ]
        )
        page = await browser.new_page()
        await page.goto(url, wait_until="networkidle", timeout=30000)
        html = await page.content()
        await browser.close()
        return html

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
    
    # Remove unwanted tags
    for tag in soup(["script", "style", "noscript", "svg", "head", "meta", "link"]):
        tag.decompose()
    for img in soup.find_all("img"):
        alt = img.get("alt", "").strip()
        src = img.get("src", "")
        # Create a natural-language description
        desc = f"[Image: {alt} | {src}]" if alt else f"[Image: {src}]"
        img.replace_with(desc)
    
    # Extract text with reasonable spacing
    text = soup.get_text(separator=" ", strip=True)
    import re
    text = re.sub(r"\s+", " ", text)
    
    return text

def extract_images(base_url: str, html: str) -> list[str]:
    soup = BeautifulSoup(html, "html.parser")
    image_urls = []
    for img in soup.find_all("img", src=True):
        url = urljoin(base_url, img["src"])
        image_urls.append(url)
    return image_urls

async def parse_structured_with_llm(text: str, source_url: str,tenant_id:str) -> list[dict]:
    """
    Use a standardized prompt to extract business catalog items from any webpage text.
    Returns a list of dictionaries with consistent schema.
    """
    prompt = f"""You are an expert data extractor.Respond ONLY with a JSON array. Do not include any other text, markdown, or explanation. The output must be parseable by json.loads(). Analyze the following text and extract all business offerings such as products, services, courses, packages, rooms, or plans.

Return a JSON list of items. Each item must be a JSON object with EXACTLY these fields:
- "item_type": one of ["product", "service", "course", "package", "room", "plan", "other"]
- "name": short, clear title (string)
- "description": concise summary (string, max 300 chars)
- "category": logical category (e.g., "Electronics", "Consulting", "Fitness") (string)
- "price": numeric price (float or null if not available)
- "discount": numeric discount amount or percentage (float or null)
- "currency": ISO currency code (e.g., "USD", "EUR") (string, default "USD")
"image_url": extract the actual image URL if mentioned in the text (e.g., from '[Image: ... | https://example.com/image.jpg]'). Return the full or relative URL as a string, or null if none is found.

If a field is unknown, use null (for price/discount) or a reasonable default (e.g., "other" for item_type).
Only return valid JSON. Do not include any other text.

Extract ONLY concrete, shoppable products that are the MAIN focus of this page.
IGNORE:
- Promotional offers (e.g., "30% off on shoes")
- Coupons, discounts, or shipping offers
- Logos, UI elements, or generic site banners
- Items that appear only in headers, footers, or side banners

Each item must represent a real product with a name and price that can be purchased.

Text:
{text[:LLM_BATCH_SIZE]}
"""

    try:
        raw_response = await llm.analysis(tenant_id,prompt)
        # Ensure response is a list of dicts
        # Parse the JSON string
        try:
            response = json.loads(raw_response)
        except json.JSONDecodeError as e:
            logger.warning(f"Failed to parse LLM JSON response from {source_url}: {e}")
            logger.debug(f"Raw LLM response: {raw_response[:500]}...")
            return []
        
        if isinstance(response, list):
            return response
        elif isinstance(response, dict) and "items" in response:
            return response["items"]
        else:
            logger.warning(f"Unexpected LLM response format from {source_url}")
            return []
    except Exception as e:
        logger.error(f"LLM parsing failed for {source_url}: {e}")
        return []

async def crawl_and_ingest(session: Session, tenant_id: str, start_url: str):
    visited, to_visit = set(), [start_url]
    pages_processed = 0
    print(f"Starting crawl for tenant {tenant_id} from {start_url}")
    catalog_list: List[BusinessCatalog] = []

    while to_visit and pages_processed < CRAWL_LIMIT:
        url = to_visit.pop()
        if url in visited:
            continue
        try:
            html = await fetch_html(url)
            print(f"Fetched {url} ({len(html)} bytes)")
            text = clean_text(html)
            print(f"Cleaned text from {url}: {len(text)} chars")

            # Step: Parse structured catalog via LLM (NO RAG)
            items = await parse_structured_with_llm(text, url,tenant_id)

            for item in items:
                # Normalize and validate fields
                catalog_entry = BusinessCatalog(
                    tenant_id=tenant_id,
                    item_type=item.get("item_type") or "other",
                    name=item.get("name") or "Unnamed Item",
                    description=item.get("description") or "",
                    category=item.get("category") or "General",
                    price=item.get("price"),
                    discount=item.get("discount"),
                    currency=item.get("currency") or "USD",  # or use settings.CURRENCY if available
                    source_url=item.get("source_url") or url,
                    image_url=item.get("image_url") or None,
                )
                #session.add(catalog_entry)
                catalog_list.append(catalog_entry)
                
            # Discover new links (same domain only)
            for link in extract_links(url, html):
                if link not in visited and link not in to_visit:
                    to_visit.append(link)

            visited.add(url)
            pages_processed += 1
            if len(catalog_list) >= CATALOG_LIMIT:
                return catalog_list
            #session.commit()
        except Exception as e:
            logger.error(f"Error processing {url}: {e}")
            #session.rollback()
    return catalog_list

async def background_crawl(tenant_id: int, url: str):
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
        catalog_list = await crawl_and_ingest(session, str(tenant_id), url)

        # Mark as done
        print(f"✅ Completed crawl for tenant {tenant_id} at {url}")
        session.execute(
            text("UPDATE web_ingest_requests SET status = 'done' WHERE tenant_id = :t AND url = :u"),
            {"t": tenant_id, "u": url}
        )
        session.commit()
        #catalog = session.query(BusinessCatalog).filter(BusinessCatalog.tenant_id == tenant_id , BusinessCatalog.source_url != "CSV_UPLOAD").all()
        return catalog_list
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

