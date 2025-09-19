-- server/migrations/003_onboarding.sql
CREATE TABLE IF NOT EXISTS business_profiles (
  tenant_id VARCHAR(64) PRIMARY KEY,
  business_name TEXT NOT NULL,
  owner_phone TEXT NOT NULL,
  language VARCHAR(8) NOT NULL DEFAULT 'en',
  business_type VARCHAR(16),
  is_active BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id VARCHAR(64) NOT NULL,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL DEFAULT 0,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_items_tenant ON items(tenant_id);

CREATE TABLE IF NOT EXISTS workflows (
  tenant_id VARCHAR(64) PRIMARY KEY,
  template TEXT NOT NULL,
  ask_name BOOLEAN NOT NULL DEFAULT true,
  ask_location BOOLEAN NOT NULL DEFAULT false,
  offer_payment BOOLEAN NOT NULL DEFAULT true,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS payments (
  tenant_id VARCHAR(64) PRIMARY KEY,
  upi_id TEXT,
  bank_details TEXT,
  checkout_link TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS web_ingest_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id VARCHAR(64) NOT NULL,
  url TEXT NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'queued',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
