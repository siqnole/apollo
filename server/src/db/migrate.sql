-- Run once to set up the database schema
-- psql -d apollo -f src/db/migrate.sql

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────
-- Users & Auth
-- ─────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  username    TEXT UNIQUE NOT NULL,
  niche       TEXT,
  bio         TEXT,
  skill_tier  TEXT NOT NULL DEFAULT 'Explorer',
  xp          INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_interests (
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interest    TEXT NOT NULL,
  PRIMARY KEY (user_id, interest)
);

CREATE TABLE IF NOT EXISTS user_goals (
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  goal        TEXT NOT NULL,
  PRIMARY KEY (user_id, goal)
);

CREATE TABLE IF NOT EXISTS social_connections (
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform    TEXT NOT NULL,
  connected   BOOLEAN NOT NULL DEFAULT FALSE,
  access_token TEXT,
  profile_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, platform)
);

CREATE TABLE IF NOT EXISTS rivals (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_a, user_b)
);

-- ─────────────────────────────────────────────────────────────────────────
-- Problems & Submissions
-- ─────────────────────────────────────────────────────────────────────────

DO $$ BEGIN
  CREATE TYPE problem_type_enum AS ENUM (
    'code', 'multiple_choice', 'fill_blank', 'debug', 'ordering', 'short_answer', 'html_css',
    'shell', 'sql', 'shell_sql', 'python_code'
  );
EXCEPTION WHEN duplicate_object THEN
  NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE submission_status_enum AS ENUM (
    'pending', 'accepted', 'wrong_answer', 'runtime_error', 'timeout', 'compile_error'
  );
EXCEPTION WHEN duplicate_object THEN
  NULL;
END $$;

CREATE TABLE IF NOT EXISTS problems (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT UNIQUE NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT NOT NULL,
  problem_type    problem_type_enum NOT NULL,
  difficulty      TEXT NOT NULL,
  category        TEXT NOT NULL,
  xp_reward       INTEGER NOT NULL DEFAULT 0,
  starter_code    JSONB,
  hints           TEXT[],
  tags            TEXT[],
  supported_languages TEXT[],
  active          BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS test_cases (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  problem_id      UUID NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  input           TEXT NOT NULL,
  expected_output TEXT NOT NULL,
  is_hidden       BOOLEAN NOT NULL DEFAULT FALSE,
  explanation     TEXT,
  display_order   INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS submissions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  problem_id      UUID NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  problem_type    problem_type_enum,
  language        TEXT,
  code            TEXT,
  answer          TEXT,
  status          submission_status_enum NOT NULL DEFAULT 'pending',
  error_message   TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────
-- Multiple Choice & Short Answer Options
-- ─────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS problem_options (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  problem_id      UUID NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  label           TEXT,
  body            TEXT NOT NULL,
  is_correct      BOOLEAN NOT NULL DEFAULT FALSE,
  display_order   INTEGER NOT NULL DEFAULT 0,
  UNIQUE (problem_id, label, body, display_order)
);

-- Keep choices as alias for backward compatibility
CREATE TABLE IF NOT EXISTS choices (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  problem_id      UUID NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  choice_letter   TEXT NOT NULL,
  choice_text     TEXT NOT NULL,
  is_correct      BOOLEAN NOT NULL DEFAULT FALSE,
  display_order   INTEGER NOT NULL DEFAULT 0
);

-- ─────────────────────────────────────────────────────────────────────────
-- Indexes
-- ─────────────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_problems_slug ON problems(slug);
CREATE INDEX IF NOT EXISTS idx_submissions_user ON submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_problem ON submissions(problem_id);
CREATE INDEX IF NOT EXISTS idx_test_cases_problem ON test_cases(problem_id);
CREATE INDEX IF NOT EXISTS idx_problem_options_problem ON problem_options(problem_id);
CREATE INDEX IF NOT EXISTS idx_choices_problem ON choices(problem_id);
CREATE INDEX IF NOT EXISTS idx_users_skill_tier ON users(skill_tier);

-- ─────────────────────────────────────────────────────────────────────────
-- Schema Migrations (for existing databases)
-- ─────────────────────────────────────────────────────────────────────────

-- Add UNIQUE constraint to prevent duplicate answers (if not already present)
ALTER TABLE problem_options
ADD CONSTRAINT unique_problem_option UNIQUE (problem_id, label, body, display_order)
ON CONFLICT DO NOTHING;

-- Remove any existing duplicates in problem_options before the unique constraint takes effect
-- Keep only the first occurrence of each (problem_id, body, display_order) combination
DELETE FROM problem_options
WHERE id IN (
  SELECT id
  FROM (
    SELECT 
      po.id,
      ROW_NUMBER() OVER (
        PARTITION BY po.problem_id, po.body, po.display_order 
        ORDER BY po.id ASC
      ) as rn
    FROM problem_options po
  ) ranked
  WHERE rn > 1
);
ALTER TABLE test_cases ADD COLUMN IF NOT EXISTS explanation TEXT;