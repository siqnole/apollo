-- Run once to set up the database schema
-- psql -d apollo -f src/db/migrate.sql

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Users ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username    TEXT UNIQUE NOT NULL,
  niche       TEXT,
  bio         TEXT,
  level       TEXT NOT NULL DEFAULT 'Explorer',
  xp          INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Interests ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_interests (
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interest    TEXT NOT NULL,
  PRIMARY KEY (user_id, interest)
);

-- ── Goals ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_goals (
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  goal        TEXT NOT NULL,
  PRIMARY KEY (user_id, goal)
);

-- ── Social connections ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS social_connections (
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform    TEXT NOT NULL,   -- 'gh' | 'li' | 'tw' | 'dev'
  connected   BOOLEAN NOT NULL DEFAULT FALSE,
  access_token TEXT,
  profile_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, platform)
);

-- ── Rivals ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rivals (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_a, user_b)
);

-- ── Index ─────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_users_level     ON users(level);
CREATE INDEX IF NOT EXISTS idx_users_username  ON users(username);