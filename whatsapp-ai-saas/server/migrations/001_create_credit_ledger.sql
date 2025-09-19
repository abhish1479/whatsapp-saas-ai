-- Creates credit_ledger and supporting enums/indexes
-- Idempotent-ish: use IF NOT EXISTS where possible.
CREATE TABLE IF NOT EXISTS credit_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id VARCHAR(64) NOT NULL,
  event_id VARCHAR(128) NOT NULL, -- webhook or app event id for idempotency
  direction VARCHAR(8) NOT NULL CHECK (direction IN ('in', 'out')), -- in = inbound user msg, out = outbound bot/agent msg
  units INTEGER NOT NULL CHECK (units >= 0),
  status VARCHAR(16) NOT NULL CHECK (status IN ('reserved','finalized','refunded','void')),
  reason_code VARCHAR(32) NOT NULL DEFAULT 'message',
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, event_id)
);

CREATE INDEX IF NOT EXISTS idx_credit_ledger_tenant_created
  ON credit_ledger (tenant_id, created_at DESC);

-- Optional wallets table (minimal)
CREATE TABLE IF NOT EXISTS wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id VARCHAR(64) UNIQUE NOT NULL,
  balance INTEGER NOT NULL DEFAULT 0,
  currency VARCHAR(8) NOT NULL DEFAULT 'CR', -- credits
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
