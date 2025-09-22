# services/credits.py
from __future__ import annotations
from typing import Optional, Dict, Any
import json

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

from services.metrics import inc_credits  # Prometheus counter


# ----------------------------
# Wallet helpers
# ----------------------------

async def ensure_wallet(db: AsyncSession, tenant_id: str) -> Dict[str, Any]:
    """
    Ensure a wallet row exists for tenant_id. Return current balance.
    Schema-aligned with:
      wallets(id uuid pk, tenant_id unique, balance int, currency text, updated_at)
    """
    await db.execute(
        text("""
            INSERT INTO wallets (tenant_id)
            VALUES (:t)
            ON CONFLICT (tenant_id) DO NOTHING
        """),
        {"t": tenant_id},
    )
    row = await db.execute(
        text("SELECT balance, currency FROM wallets WHERE tenant_id = :t"),
        {"t": tenant_id},
    )
    bal, cur = row.first() if row.returns_rows else (0, "CR")
    return {"tenant_id": tenant_id, "balance": int(bal), "currency": cur}


async def get_balance(db: AsyncSession, tenant_id: str) -> int:
    row = await db.execute(
        text("SELECT balance FROM wallets WHERE tenant_id = :t"),
        {"t": tenant_id},
    )
    val = row.scalar()
    return int(val or 0)


# ----------------------------
# Top-up credits (finalized inbound)
# ----------------------------

async def credit(
    db: AsyncSession,
    tenant_id: str,
    amount: int,
    reason_code: str = "topup",
    metadata: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """
    Top-up (inbound) – creates a FINALIZED ledger entry and increases wallet balance.
    """
    if amount <= 0:
        raise ValueError("amount must be positive")

    await ensure_wallet(db, tenant_id)

    # 1) Ledger entry (finalized)
    await db.execute(
        text("""
            INSERT INTO credit_ledger
              (tenant_id, event_id, direction, units, status, reason_code, metadata)
            VALUES
              (:t, CONCAT('topup-', gen_random_uuid()::text), 'in', :u, 'finalized', :r, :m::jsonb)
        """),
        {"t": tenant_id, "u": amount, "r": reason_code, "m": json.dumps(metadata or {})},
    )

    # 2) Apply to wallet
    await db.execute(
        text("""
            UPDATE wallets
               SET balance = balance + :u,
                   updated_at = now()
             WHERE tenant_id = :t
        """),
        {"t": tenant_id, "u": amount},
    )

    # 3) Metrics
    inc_credits(tenant_id=tenant_id, reason_code=reason_code, units=amount)

    return await ensure_wallet(db, tenant_id)


# ----------------------------
# Reservation / settlement
# ----------------------------

async def reserve(
    db: AsyncSession,
    tenant_id: str,
    event_id: str,
    direction: str,   # 'in' | 'out'
    units: int,
    reason_code: str,
    metadata: Optional[Dict[str, Any]] = None,
) -> None:
    """
    Create a RESERVED ledger row (idempotent on (tenant_id, event_id)).
    Does NOT change wallet balance.
    """
    if direction not in ("in", "out"):
        raise ValueError("direction must be 'in' or 'out'")
    if units < 0:
        raise ValueError("units must be >= 0")

    await ensure_wallet(db, tenant_id)

    await db.execute(
        text("""
            INSERT INTO credit_ledger
              (tenant_id, event_id, direction, units, status, reason_code, metadata)
            VALUES
              (:t, :e, :d, :u, 'reserved', :r, :m::jsonb)
            ON CONFLICT (tenant_id, event_id) DO NOTHING
        """),
        {"t": tenant_id, "e": event_id, "d": direction, "u": units,
         "r": reason_code, "m": json.dumps(metadata or {})},
    )


async def finalize(db: AsyncSession, tenant_id: str, event_id: str):
    """
    FINALIZE a reserved entry and apply to wallet:
      - direction='out' -> subtract units
      - direction='in'  -> add units
    Idempotent: if already finalized/refunded/void, no double-apply.
    Returns the row (as mapping) or None if not found.
    """
    row = await db.execute(
        text("""
            SELECT id, direction, units, reason_code, status
              FROM credit_ledger
             WHERE tenant_id = :t AND event_id = :e
        """),
        {"t": tenant_id, "e": event_id},
    )
    entry = row.mappings().first()
    if not entry:
        return None

    if entry["status"] == "finalized":
        # Already applied – emit metric and return
        inc_credits(tenant_id=tenant_id, reason_code=entry["reason_code"], units=int(entry["units"]))
        return entry

    if entry["status"] in ("refunded", "void"):
        # Terminal states – do not apply to wallet
        return entry

    # Mark finalized
    await db.execute(
        text("""
            UPDATE credit_ledger
               SET status = 'finalized', updated_at = now()
             WHERE tenant_id = :t AND event_id = :e AND status = 'reserved'
        """),
        {"t": tenant_id, "e": event_id},
    )

    # Apply to wallet
    sign = 1 if entry["direction"] == "in" else -1
    delta = sign * int(entry["units"])

    await db.execute(
        text("""
            UPDATE wallets
               SET balance = balance + :delta,
                   updated_at = now()
             WHERE tenant_id = :t
        """),
        {"t": tenant_id, "delta": delta},
    )

    inc_credits(tenant_id=tenant_id, reason_code=entry["reason_code"], units=int(entry["units"]))
    return entry


# ----------------------------
# Safeguards around reserved items
# ----------------------------

async def void_reserved(db: AsyncSession, tenant_id: str, event_id: str) -> bool:
    """
    Mark a RESERVED entry as VOID (no wallet effect). Returns True if updated.
    """
    res = await db.execute(
        text("""
            UPDATE credit_ledger
               SET status = 'void', updated_at = now()
             WHERE tenant_id = :t AND event_id = :e AND status = 'reserved'
        """),
        {"t": tenant_id, "e": event_id},
    )
    return res.rowcount > 0


async def refund_finalized(db: AsyncSession, tenant_id: str, event_id: str) -> bool:
    """
    Refund a FINALIZED entry:
      - Set status='refunded'
      - Reverse wallet effect
    Returns True if refunded.
    """
    row = await db.execute(
        text("""
            SELECT direction, units, status, reason_code
              FROM credit_ledger
             WHERE tenant_id = :t AND event_id = :e
        """),
        {"t": tenant_id, "e": event_id},
    )
    entry = row.mappings().first()
    if not entry or entry["status"] != "finalized":
        return False

    # Mark refunded
    await db.execute(
        text("""
            UPDATE credit_ledger
               SET status = 'refunded', updated_at = now()
             WHERE tenant_id = :t AND event_id = :e AND status = 'finalized'
        """),
        {"t": tenant_id, "e": event_id},
    )

    # Reverse wallet effect of the finalized entry
    sign = -1 if entry["direction"] == "in" else 1
    delta = sign * int(entry["units"])

    await db.execute(
        text("""
            UPDATE wallets
               SET balance = balance + :delta,
                   updated_at = now()
             WHERE tenant_id = :t
        """),
        {"t": tenant_id, "delta": delta},
    )

    inc_credits(tenant_id=tenant_id, reason_code=f"{entry['reason_code']}:refund", units=int(entry["units"]))
    return True
