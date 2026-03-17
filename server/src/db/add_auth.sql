-- Run: psql -d apollo -f /tmp/add_auth.sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS email         TEXT UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);