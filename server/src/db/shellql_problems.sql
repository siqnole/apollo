-- ── Shell+SQL Problems ────────────────────────────────────────────────────
ALTER TYPE problem_type ADD VALUE IF NOT EXISTS 'shell_sql';

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'run-migration',
  'Write and Run a Migration',
  E'The `users` table exists but is missing two columns needed for the auth system.\n\nWrite a file called `migration.sql` that adds:\n- `email` — TEXT, NOT NULL DEFAULT `''''`\n- `verified` — BOOLEAN, NOT NULL DEFAULT `false`\n\nThen run it against the live database:\n```bash\npsql -f migration.sql\n```\n\nVerify with:\n```bash\npsql -c "\\d users"\n```\n\nType `check` when done.',
  'shell_sql', 'Medium', 'Databases', 140,
  ARRAY[
    'ALTER TABLE users ADD COLUMN col_name TYPE DEFAULT value;',
    'You can add multiple columns in one ALTER TABLE statement',
    'psql -f filename.sql runs a SQL file against the database',
    'psql -c "\\d tablename" shows the table schema'
  ],
  ARRAY['sql', 'psql', 'migration', 'alter-table', 'sysadmin', 'databases'],
  ARRAY['shell']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'add-index',
  'Add Missing Indexes',
  E'The `orders` table has 1000 rows but **no indexes**. Queries filtering by `customer_id` or `status` are doing full table scans.\n\nCreate two indexes:\n1. `idx_orders_customer_id` on `orders(customer_id)`\n2. `idx_orders_status` on `orders(status)`\n\nVerify they exist:\n```bash\npsql -c "\\di orders*"\n```\n\nType `check` when done.',
  'shell_sql', 'Medium', 'Databases', 130,
  ARRAY[
    'CREATE INDEX idx_name ON table(column);',
    'psql -c "\\di orders*" lists indexes on the orders table',
    'Or: SELECT indexname FROM pg_indexes WHERE tablename = ''orders'';',
    'Indexes speed up WHERE, JOIN, and ORDER BY on indexed columns'
  ],
  ARRAY['sql', 'psql', 'indexes', 'performance', 'sysadmin', 'databases'],
  ARRAY['shell']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'fix-migration',
  'Fix the Broken Migration',
  E'A migration file `migration.sql` is waiting in your home directory.\n\nIt has **3 bugs** that prevent it from running. Find them, fix them, then run the migration:\n```bash\npsql -f migration.sql\n```\n\n**What the migration should do:**\n- Add a `stock_count` INTEGER column to `products`\n- Create a unique index `idx_products_name` on `products(name)`\n- Set `stock_count = 100` for all electronics\n\nType `check` when done.',
  'shell_sql', 'Hard', 'Databases', 200,
  ARRAY[
    'Run psql -f migration.sql and read the error message carefully',
    'SQL uses single quotes for strings, not double quotes',
    'Check every keyword spelling — typos in type names cause errors',
    'CREATE INDEX syntax: CREATE INDEX name ON table(column) — no INDX',
    'DEFAULT not DEFALT, INTEGER not INTEGR'
  ],
  ARRAY['sql', 'psql', 'migration', 'debug', 'sysadmin', 'databases'],
  ARRAY['shell']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;