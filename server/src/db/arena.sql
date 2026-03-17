-- ── Problems ───────────────────────────────────────────────────────────────
CREATE TYPE problem_type AS ENUM (
  'code', 'multiple_choice', 'fill_blank', 'debug', 'ordering', 'short_answer'
);
CREATE TYPE difficulty AS ENUM ('Easy', 'Medium', 'Hard', 'Expert');

CREATE TABLE IF NOT EXISTS problems (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug         TEXT UNIQUE NOT NULL,
  title        TEXT NOT NULL,
  description  TEXT NOT NULL,          -- markdown
  problem_type problem_type NOT NULL,
  difficulty   difficulty NOT NULL,
  category     TEXT NOT NULL,          -- e.g. 'Algorithms', 'Data Structures'
  xp_reward    INTEGER NOT NULL DEFAULT 50,
  starter_code JSONB,                  -- { js, ts, python, c, cpp, csharp }
  hints        TEXT[],
  tags         TEXT[],
  active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Test cases (for code/debug/fill_blank problems) ────────────────────────
CREATE TABLE IF NOT EXISTS test_cases (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  problem_id      UUID NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  input           TEXT NOT NULL,
  expected_output TEXT NOT NULL,
  is_hidden       BOOLEAN NOT NULL DEFAULT FALSE,
  explanation     TEXT,
  display_order   INTEGER NOT NULL DEFAULT 0
);

-- ── Options (for multiple_choice / ordering problems) ─────────────────────
CREATE TABLE IF NOT EXISTS problem_options (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  problem_id    UUID NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  label         TEXT NOT NULL,         -- 'A', 'B', 'C' or '1','2','3' for ordering
  body          TEXT NOT NULL,
  is_correct    BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INTEGER NOT NULL DEFAULT 0
);

-- ── Submissions ────────────────────────────────────────────────────────────
CREATE TYPE submission_status AS ENUM (
  'pending', 'running', 'accepted', 'wrong_answer',
  'runtime_error', 'time_limit', 'compile_error'
);

CREATE TABLE IF NOT EXISTS submissions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  problem_id    UUID NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
  problem_type  problem_type NOT NULL,
  language      TEXT,                  -- 'javascript','typescript','python','c','cpp','csharp'
  code          TEXT,                  -- for code submissions
  answer        TEXT,                  -- for MC/fill/ordering/short_answer
  status        submission_status NOT NULL DEFAULT 'pending',
  output        TEXT,                  -- actual output or error
  expected      TEXT,                  -- expected output (for wrong_answer)
  runtime_ms    INTEGER,
  test_results  JSONB,                 -- array of {input, expected, actual, passed}
  xp_awarded    INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_submissions_user    ON submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_problem ON submissions(problem_id);
CREATE INDEX IF NOT EXISTS idx_problems_slug       ON problems(slug);
CREATE INDEX IF NOT EXISTS idx_problems_category   ON problems(category);