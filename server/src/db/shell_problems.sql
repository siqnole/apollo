-- Add shell to the problem_type enum
ALTER TYPE problem_type ADD VALUE IF NOT EXISTS 'shell';

-- ── Shell / Sysadmin Problems ──────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'find-misplaced-config',
  'Find the Misplaced Config',
  E'An nginx config file has ended up in the wrong directory during a rushed deploy.\n\nYour job: **find** `nginx.conf` and **move** it to `/etc/nginx/` where it belongs.\n\nThe filesystem has been set up for you. Start by exploring what''s here.\n\n**Goal:** `nginx.conf` must be in `/etc/nginx/` and no longer in its current wrong location.',
  'shell', 'Easy', 'Sysadmin', 80,
  ARRAY[
    'Use `find . -name "nginx.conf"` to locate the file',
    'Use `mv <source> <destination>` to move it',
    '`tree` or `ls -R` gives you a full picture of the filesystem'
  ],
  ARRAY['linux', 'filesystem', 'find', 'mv', 'sysadmin'],
  ARRAY['shell']
)
ON CONFLICT (slug) DO UPDATE SET
  description = EXCLUDED.description,
  hints = EXCLUDED.hints;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'bulk-rename-logs',
  'Bulk Rename Log Files',
  E'You have 6 log files in `logs/` named in the format `access_YYYY-MM-DD.log`.\n\nRename all of them to `YYYY-MM-DD.access.log` — swapping the prefix to a suffix.\n\nThe file `error.log` should be left untouched.\n\n**Before:** `access_2024-01-15.log`\n**After:** `access_2024-01-15.log` → `2024-01-15.access.log`',
  'shell', 'Medium', 'Sysadmin', 120,
  ARRAY[
    'A for loop with `mv` works: `for f in logs/access_*.log; do ...`',
    '`basename` strips the directory: `basename access_2024-01-15.log .log` → `access_2024-01-15`',
    'Parameter expansion: `${f#logs/access_}` strips the prefix',
    'Or use `rename` if available: `rename ''s/access_(\d{4}-\d{2}-\d{2})/$1.access/'' logs/*.log`'
  ],
  ARRAY['linux', 'bash', 'rename', 'mv', 'glob', 'sysadmin'],
  ARRAY['shell']
)
ON CONFLICT (slug) DO UPDATE SET
  description = EXCLUDED.description,
  hints = EXCLUDED.hints;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'grep-errors',
  'Hunt Down the Errors',
  E'You have 5 service log files in `services/`.\n\nFind all files that contain the word **ERROR** and write their **filenames** (not full paths) to a file called `found.txt` in your home directory — one filename per line.\n\n**Example output in found.txt:**\n```\nauth.log\nworker.log\n```',
  'shell', 'Easy', 'Sysadmin', 80,
  ARRAY[
    '`grep -l "ERROR" services/*.log` lists only filenames with matches',
    '`grep -rl "ERROR" services/` works recursively',
    'Redirect output with `>`: `grep -l "ERROR" services/*.log > found.txt`',
    '`basename` strips the path if you get full paths: `grep -l "ERROR" services/*.log | xargs -I{} basename {}`'
  ],
  ARRAY['linux', 'grep', 'redirect', 'bash', 'sysadmin'],
  ARRAY['shell']
)
ON CONFLICT (slug) DO UPDATE SET
  description = EXCLUDED.description,
  hints = EXCLUDED.hints;