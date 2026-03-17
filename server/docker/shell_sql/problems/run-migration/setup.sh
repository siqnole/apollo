#!/bin/bash
# Setup: users table exists but is missing the email column
# User must write a migration file and run it with psql

psql -c "
CREATE TABLE IF NOT EXISTS users (
  id         SERIAL PRIMARY KEY,
  username   TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO users (username) VALUES ('alice'), ('bob'), ('carol');
" 2>/dev/null

cat > /home/user/README.txt << 'EOF'
TASK
----
The users table is missing an email column.

Write a migration file called migration.sql that adds:
  - An `email` column (TEXT, NOT NULL DEFAULT '')
  - A `verified` column (BOOLEAN, NOT NULL DEFAULT false)

Then run it against the database:
  psql -f migration.sql

Check your work:
  psql -c "\d users"

Type `check` when done.
EOF

chown user:user /home/user/README.txt