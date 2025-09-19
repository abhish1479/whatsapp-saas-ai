import os, json, asyncio, logging
import aioredis
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
from server.services.credits import reserve
from server.services.metrics import inc_message  # <-- added

logging.basicConfig(level=logging.INFO)

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
QUEUE_KEY = os.getenv("WEBHOOK_QUEUE", "wh_inbound_queue")
GROUP = os.getenv("WEBHOOK_GROUP", "grp1")
CONSUMER = os.getenv("WEBHOOK_CONSUMER", "c1")
DB_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost:5432/app")

engine = create_async_engine(DB_URL, echo=False, pool_pre_ping=True)
SessionLocal = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)

async def handle_event(event_id: str, payload: dict):
    tenant_id = payload.get("tenant_id", "unknown")
    async with SessionLocal() as session:
        await reserve(session, tenant_id=tenant_id, event_id=event_id+"-in", direction='in', units=0, reason_code='inbound', metadata={"raw": True})
        await session.commit()
    # increment inbound message metric
    inc_message(tenant_id, 'in')
    # TODO: when sending outbound, call inc_message(tenant_id,'out')

async def main():
    r = await aioredis.from_url(REDIS_URL, decode_responses=True)
    try:
        await r.xgroup_create(name=QUEUE_KEY, groupname=GROUP, id="$", mkstream=True)
    except Exception:
        pass
    while True:
        resp = await r.xreadgroup(groupname=GROUP, consumername=CONSUMER, streams={QUEUE_KEY: '>'}, count=10, block=5000)
        if not resp:
            continue
        for stream_key, messages in resp:
            for msg_id, fields in messages:
                try:
                    event_id = fields.get("event_id")
                    payload = json.loads(fields.get("payload", "{}"))
                    await handle_event(event_id, payload)
                    await r.xack(QUEUE_KEY, GROUP, msg_id)
                except Exception as e:
                    logging.exception("Processing failed for %s: %s", msg_id, e)

if __name__ == "__main__":
    asyncio.run(main())
