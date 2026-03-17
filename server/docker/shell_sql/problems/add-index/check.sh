#!/bin/bash
PASS=true

IDX1=$(psql -tAc "SELECT indexname FROM pg_indexes WHERE tablename='orders' AND indexname='idx_orders_customer_id'" 2>/dev/null | tr -d ' ')
IDX2=$(psql -tAc "SELECT indexname FROM pg_indexes WHERE tablename='orders' AND indexname='idx_orders_status'" 2>/dev/null | tr -d ' ')

if [ -z "$IDX1" ]; then
  echo "✗ idx_orders_customer_id not found"
  PASS=false
else
  echo "✓ idx_orders_customer_id exists"
fi

if [ -z "$IDX2" ]; then
  echo "✗ idx_orders_status not found"
  PASS=false
else
  echo "✓ idx_orders_status exists"
fi

# Verify they actually index the right columns
COL1=$(psql -tAc "SELECT a.attname FROM pg_index i JOIN pg_class c ON c.oid=i.indrelid JOIN pg_attribute a ON a.attrelid=c.oid AND a.attnum=ANY(i.indkey) WHERE c.relname='orders' AND i.indrelid::regclass::text='orders' AND i.indkey[0]=(SELECT attnum FROM pg_attribute WHERE attrelid='orders'::regclass AND attname='customer_id')" 2>/dev/null | tr -d ' ')
if [ "$COL1" != "customer_id" ]; then
  echo "✗ idx_orders_customer_id doesn't index the customer_id column"
  PASS=false
fi

if $PASS; then
  echo "Both indexes created correctly!"
  exit 0
fi
exit 1