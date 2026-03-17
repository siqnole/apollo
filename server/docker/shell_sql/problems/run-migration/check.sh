#!/bin/bash
PASS=true

# Check email column exists
EMAIL=$(psql -tAc "SELECT column_name FROM information_schema.columns WHERE table_name='users' AND column_name='email'" 2>/dev/null)
if [ -z "$EMAIL" ]; then
  echo "✗ a specified column was not found on users table"
  PASS=false
else
  echo "✓ email column exists"
fi

# Check verified column exists
VERIFIED=$(psql -tAc "SELECT column_name FROM information_schema.columns WHERE table_name='users' AND column_name='verified'" 2>/dev/null)
if [ -z "$VERIFIED" ]; then
  echo "✗ a specified column was not found on users table"
  PASS=false
else
  echo "✓ verified column exists"
fi

# Check data types
EMAIL_TYPE=$(psql -tAc "SELECT data_type FROM information_schema.columns WHERE table_name='users' AND column_name='email'" 2>/dev/null | tr -d ' ')
VERIFIED_TYPE=$(psql -tAc "SELECT data_type FROM information_schema.columns WHERE table_name='users' AND column_name='verified'" 2>/dev/null | tr -d ' ')

if [ "$EMAIL_TYPE" != "text" ] && [ "$EMAIL_TYPE" != "charactervarying" ]; then
  echo "✗ email should be TEXT type, got: $EMAIL_TYPE"
  PASS=false
fi

if [ "$VERIFIED_TYPE" != "boolean" ]; then
  echo "✗ verified should be BOOLEAN type, got: $VERIFIED_TYPE"
  PASS=false
fi

# Check existing rows still intact
ROW_COUNT=$(psql -tAc "SELECT COUNT(*) FROM users" 2>/dev/null | tr -d ' ')
if [ "$ROW_COUNT" != "3" ]; then
  echo "✗ Expected 3 rows in users, found $ROW_COUNT — did you accidentally drop the table?"
  PASS=false
else
  echo "✓ Existing rows preserved"
fi

if $PASS; then
  echo "Migration applied correctly!"
  exit 0
fi
exit 1