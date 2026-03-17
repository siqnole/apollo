#!/bin/bash
# Pass if all access_YYYY-MM-DD.log files are renamed to YYYY-MM-DD.access.log
# and no access_*.log files remain, and error.log is untouched

EXPECTED=("2024-01-15" "2024-01-16" "2024-01-17" "2024-01-18" "2024-01-19" "2024-01-20")
PASS=true

for date in "${EXPECTED[@]}"; do
  if [ ! -f "/home/user/logs/${date}.access.log" ]; then
    echo "Missing: ${date}.access.log"
    PASS=false
  fi
  if [ -f "/home/user/logs/access_${date}.log" ]; then
    echo "Old file still exists: access_${date}.log"
    PASS=false
  fi
done

if [ ! -f "/home/user/logs/error.log" ]; then
  echo "error.log was modified or deleted — it should be untouched"
  PASS=false
fi

if $PASS; then
  echo "All 6 files renamed correctly and error.log untouched!"
  exit 0
else
  exit 1
fi