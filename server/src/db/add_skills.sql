-- Rename level to skill_tier (used for rival matching only)
-- XP-based rank is now computed, not stored
ALTER TABLE users RENAME COLUMN level TO skill_tier;