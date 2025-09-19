from __future__ import annotations
from typing import Optional, Literal, Dict, Any
from dataclasses import dataclass
import uuid, datetime as dt, json as _json

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from server.services.metrics import inc_credits  # <-- added

Direction = Literal["in","out"]
Status = Literal["reserved","finalized","refunded","void"]

@dataclass
class LedgerEntry:
    id: str
    tenant_id: str
    event_id: str
    direction: Direction
    units: int
    status: Status
    reason_code: str
    metadata: Dict[str, Any]
    created_at: dt.datetime
    updated_at: dt.datetime

# ... existing SQL definitions ...

async def finalize(session: AsyncSession, *, tenant_id: str, event_id: str) -> Optional[LedgerEntry]:
    row = await session.execute(text("""
    UPDATE credit_ledger
       SET status='finalized', updated_at=now()
     WHERE tenant_id=:tenant_id AND event_id=:event_id AND status='reserved'
    RETURNING id, tenant_id, event_id, direction, units, status, reason_code, metadata, created_at, updated_at
    """), {"tenant_id": tenant_id, "event_id": event_id})
    rec = row.first()
    if rec:
        entry = LedgerEntry(*rec)
        # increment metrics here
        if entry.direction == 'out':
            inc_credits(tenant_id=tenant_id, reason_code=entry.reason_code, units=entry.units)
        return entry
    return None

def json_dumps(obj): return _json.dumps(obj, separators=(',',':'))
