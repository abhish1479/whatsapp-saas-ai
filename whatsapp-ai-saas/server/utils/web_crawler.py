import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, VirtualScrollConfig

async def scrape_single_page(url: str) -> str:
    scroll_config = VirtualScrollConfig(
        container_selector=".product-wrap",  # or try: "[data-product]", ".product-card", etc.
        scroll_count=10,                     # scroll 10 times to load more products
        scroll_by="container_height",        # smart scroll
        wait_after_scroll=1.5                # wait for API + render
    )

    run_config = CrawlerRunConfig(
        virtual_scroll_config=scroll_config,
        # Optional: wait for a specific element to appear
        # wait_for_selector=".product-card",  # if you know the class
        magic=True  # enables auto-detection of dynamic content (v0.7+)
    )

    async with AsyncWebCrawler(verbose=True) as crawler:
        result = await crawler.arun(url=url, config=run_config)
        return result.markdown
