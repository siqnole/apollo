-- Rename level to skill_tier (used for rival matching only)
-- XP-based rank is now computed, not stored
-- Only run if the column exists (for backward compatibility with old schemas)
DO $$ BEGIN
  ALTER TABLE users RENAME COLUMN level TO skill_tier;
EXCEPTION WHEN undefined_column THEN
  NULL;
END $$;