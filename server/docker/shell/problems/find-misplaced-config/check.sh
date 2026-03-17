#!/bin/bash
# Pass if nginx.conf is in /home/user/etc/nginx/ (any subdir) and NOT in /home/user/tmp/

CORRECT=$(find /home/user/etc/nginx -name "nginx.conf" 2>/dev/null | head -1)
STILL_IN_TMP=$(find /home/user/tmp -name "nginx.conf" 2>/dev/null | head -1)

if [ -n "$CORRECT" ] && [ -z "$STILL_IN_TMP" ]; then
  echo "nginx.conf found at $CORRECT — correct!"
  exit 0
elif [ -n "$STILL_IN_TMP" ] && [ -n "$CORRECT" ]; then
  echo "nginx.conf was copied but the original in /tmp still exists — remove it too."
  exit 1
elif [ -n "$STILL_IN_TMP" ]; then
  echo "nginx.conf is still in /tmp. Move it to /etc/nginx/"
  exit 1
else
  echo "nginx.conf not found anywhere. Did you accidentally delete it?"
  exit 1
fi