#!/bin/bash
# Setup: a broken migration.sql is waiting to be fixed and run

psql -U postgres -c "
CREATE TABLE IF NOT EXISTS products (
  id       SERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  price    NUMERIC(10,2) NOT NULL,
  category TEXT NOT NULL DEFAULT 'general'
);
INSERT INTO products (name, price, category) VALUES
  ('Keyboard', 79.99, 'electronics'),
  ('Mouse',    29.99, 'electronics'),
  ('Desk',    199.99, 'furniture');
" 2>/dev/null

# Plant the broken migration — exactly 3 bugs:
# 1. INTEGR  → INTEGER
# 2. DEFALT  → DEFAULT
# 3. "electronics" → 'electronics'  (double quotes instead of single)
cat > /home/user/migration.sql << 'EOF'
-- Migration: add stock tracking to products
-- This file has bugs preventing it from running.
-- Find and fix them, then run:
--   psql -f migration.sql

ALTER TABLE products
  ADD COLUMN stock_count INTEGR NOT NULL DEFALT 0;

CREATE UNIQUE INDEX idx_products_name ON products(name);

UPDATE products SET stock_count = 100 WHERE category = "electronics";
EOF

cat > /home/user/README.txt << 'EOF'
TASK
----
migration.sql has bugs preventing it from running.

Find and fix all of them, then run the migration:
  psql -f migration.sql

Hints:
  - Read the error messages carefully
  - psql -c "\d products" shows the current schema
  - Run psql -f migration.sql after each fix attempt

Type `check` when done.
EOF

chown -R user:user /home/user/