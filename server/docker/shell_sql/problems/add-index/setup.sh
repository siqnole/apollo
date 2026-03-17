#!/bin/bash
# Setup: orders table with no indexes, slow queries on customer_id and status

psql -c "
CREATE TABLE IF NOT EXISTS customers (
  id   SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS orders (
  id          SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(id),
  status      TEXT NOT NULL DEFAULT 'pending',
  total       NUMERIC(10,2),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO customers (name) SELECT 'Customer ' || i FROM generate_series(1,100) i;
INSERT INTO orders (customer_id, status, total)
  SELECT (random()*99+1)::int, (ARRAY['pending','completed','cancelled'])[floor(random()*3+1)], (random()*500)::numeric(10,2)
  FROM generate_series(1,1000);
" 2>/dev/null

cat > /home/user/README.txt << 'EOF'
TASK
----
The orders table has 1000 rows but no indexes.
Queries filtering by customer_id or status are doing full table scans.

Create two indexes:
  1. idx_orders_customer_id  on orders(customer_id)
  2. idx_orders_status       on orders(status)

Verify they exist with:
  psql -c "\di orders*"

or:
  psql -c "SELECT indexname FROM pg_indexes WHERE tablename = 'orders';"

Type `check` when done.
EOF

chown user:user /home/user/README.txt