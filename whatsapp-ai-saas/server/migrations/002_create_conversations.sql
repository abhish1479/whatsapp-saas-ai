CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id VARCHAR(64) NOT NULL,
  lead_id UUID,
  status VARCHAR(16) NOT NULL DEFAULT 'open',
  summary TEXT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  tenant_id VARCHAR(64) NOT NULL,
  sender VARCHAR(16) NOT NULL, -- 'user' or 'agent'
  direction VARCHAR(8) NOT NULL, -- 'in' or 'out'
  body TEXT,
  media_url TEXT,
  credits INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS moderation_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id VARCHAR(64) NOT NULL,
  conversation_id UUID,
  message_id UUID,
  reason TEXT,
  risk_score NUMERIC,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_convo_created ON messages(conversation_id, created_at);
CREATE INDEX IF NOT EXISTS idx_moderation_tenant ON moderation_logs(tenant_id, created_at DESC);
