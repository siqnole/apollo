#!/bin/bash
# Setup: 6 log files named access_YYYY-MM-DD.log, user must rename them to YYYY-MM-DD.access.log

mkdir -p /home/user/logs

for date in 2024-01-15 2024-01-16 2024-01-17 2024-01-18 2024-01-19 2024-01-20; do
  echo "192.168.1.1 - - [${date}] GET / 200" > /home/user/logs/access_${date}.log
done

# A non-matching file that should be left alone
echo "error content" > /home/user/logs/error.log

chown -R user:user /home/user/logs