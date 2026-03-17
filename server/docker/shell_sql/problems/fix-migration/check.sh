#!/bin/bash
PASS=true

# 1. stock_count column exists with correct type
STOCK=$(psql -tAc "SELECT data_type FROM information_schema.columns WHERE table_name='products' AND column_name='stock_count'" 2>/dev/null | tr -d ' ')
if [ -z "$STOCK" ]; then
  echo "✗ stock_count column not found — migration may not have run"
  PASS=false
elif [ "$STOCK" != "integer" ]; then
  echo "✗ stock_count should be INTEGER, got: $STOCK"
  PASS=false
else
  echo "✓ stock_count column exists as INTEGER"
fi

# 2. Unique index on products.name exists
IDX=$(psql -tAc "SELECT indexname FROM pg_indexes WHERE tablename='products' AND indexname='idx_products_name'" 2>/dev/null | tr -d ' ')
if [ -z "$IDX" ]; then
  echo "✗ idx_products_name index not found"
  PASS=false
else
  echo "✓ idx_products_name index exists"
fi

# 3. Electronics products have stock_count = 100
ELEC=$(psql -tAc "SELECT COUNT(*) FROM products WHERE category='electronics' AND stock_count=100" 2>/dev/null | tr -d ' ')
if [ "$ELEC" != "2" ]; then
  echo "✗ Expected 2 electronics products with stock_count=100, found $ELEC"
  PASS=false
else
  echo "✓ Electronics stock counts updated correctly"
fi

# 4. Original rows still intact
TOTAL=$(psql -tAc "SELECT COUNT(*) FROM products" 2>/dev/null | tr -d ' ')
if [ "$TOTAL" != "3" ]; then
  echo "✗ Expected 3 products, found $TOTAL"
  PASS=false
else
  echo "✓ All original rows intact"
fi

if $PASS; then
  echo "All 3 bugs fixed and migration applied successfully!"
  exit 0
fi
exit 1