-- ── Appeals table ─────────────────────────────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f appeals.sql

CREATE TABLE IF NOT EXISTS appeals (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID REFERENCES users(id) ON DELETE SET NULL,
  slug       TEXT NOT NULL,
  reason     TEXT NOT NULL,
  status     TEXT NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending', 'cleared', 'upheld')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_appeals_status     ON appeals(status);
CREATE INDEX IF NOT EXISTS idx_appeals_user_id    ON appeals(user_id);
CREATE INDEX IF NOT EXISTS idx_appeals_created_at ON appeals(created_at DESC);
-- Add code column to appeals so admins can review what was pasted
ALTER TABLE appeals ADD COLUMN IF NOT EXISTS code TEXT;