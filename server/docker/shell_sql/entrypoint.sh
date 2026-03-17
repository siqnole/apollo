#!/bin/bash
set -e

# Start postgres as the postgres system user
su -c "/usr/lib/postgresql/14/bin/pg_ctl start -D /var/lib/postgresql/14/main -l /tmp/pg.log -w" postgres

# Wait until postgres is actually accepting connections (up to 15s)
for i in $(seq 1 15); do
  if su -c "pg_isready -q" postgres; then
    break
  fi
  echo "Waiting for postgres... ($i)"
  sleep 1
done

# Create the apollo role and database
su -c "psql -U postgres -c \"CREATE ROLE apollo WITH LOGIN PASSWORD 'apollo';\" postgres" postgres 2>/dev/null || true
su -c "psql -U postgres -c \"CREATE DATABASE apollo OWNER apollo;\" postgres" postgres 2>/dev/null || true

# Run problem setup as the user
PROBLEM=${PROBLEM:-unknown}
su -c "setup-problem $PROBLEM" user

# Stay alive for docker exec
tail -f /dev/null