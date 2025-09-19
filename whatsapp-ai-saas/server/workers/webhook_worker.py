# server/workers/webhook_worker.py

import os, json, asyncio, logging
import aioredis
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

from server.services.credits import reserve, finalize
from server.services.metrics import inc_message, inc_credits
from server.services.moderation import moderate_message

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

    # === Inbound handling ===
    async with SessionLocal() as session:
        await reserve(
            session,
            tenant_id=tenant_id,
            event_id=event_id + "-in",
            direction="in",
            units=0,
            reason_code="inbound",
            metadata={"raw": True},
        )
        await session.commit()

    # Prometheus: count inbound message
    inc_message(tenant_id, "in")

    # === Outbound reply (placeholder logic) ===
    outbound_text = "Hello, thanks for reaching out!"  # replace with LLM/template result

    async with SessionLocal() as session:
        # Moderation before sending
        result = await moderate_message(
            tenant_id=tenant_id,
            message=outbound_text,
            db=session,
            conversation_id=payload.get("conversation_id"),
            message_id=None,
        )
        if not result["allowed"]:
            logging.warning(f"[Moderation] Blocked outbound message: {result}")
            return  # HOLD, don't send

        # TODO: Send outbound via WhatsApp BSP / Cloud API
        send_ok = True  # replace with API call + response check

        if send_ok:
            # Reserve + finalize credits for outbound
            event_out_id = event_id + "-out"
            await reserve(
                session,
                tenant_id=tenant_id,
                event_id=event_out_id,
                direction="out",
                units=1,
                reason_code="message",
                metadata={"auto": True},
            )
            await session.commit()

            entry = await finalize(session, tenant_id=tenant_id, event_id=event_out_id)
            await session.commit()

            # Prometheus: count outbound + credits
            inc_message(tenant_id, "out")
            if entry:
                inc_credits(tenant_id, entry.reason_code, entry.units)

            logging.info(f"[Outbound] Sent reply for tenant={tenant_id}, event={event_id}")


async def main():
    r = await aioredis.from_url(REDIS_URL, decode_responses=True)
    try:
        await r.xgroup_create(name=QUEUE_KEY, groupname=GROUP, id="$", mkstream=True)
    except Exception:
        pass

    while True:
        resp = await r.xreadgroup(
            groupname=GROUP,
            consumername=CONSUMER,
            streams={QUEUE_KEY: ">"},
            count=10,
            block=5000,
        )
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
