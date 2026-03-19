-- Add supported_languages column
ALTER TABLE problems ADD COLUMN IF NOT EXISTS supported_languages TEXT[] NOT NULL DEFAULT '{}';

-- High-level only (existing problems with js/ts/py starters)
UPDATE problems SET supported_languages = ARRAY['javascript','typescript','python']
WHERE slug IN ('two-sum','valid-palindrome','debug-off-by-one','fizzbuzz','binary-search','explain-recursion','sql-fill-join','big-o-binary-search','http-idempotent-methods','css-box-model-order');

-- HTML/CSS problems
UPDATE problems SET supported_languages = ARRAY['html']
WHERE problem_type = 'html_css';

-- Multiple choice / theory — language-agnostic
UPDATE problems SET supported_languages = ARRAY['any']
WHERE problem_type IN ('multiple_choice','fill_blank','ordering','short_answer');