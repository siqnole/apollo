#!/bin/bash

# Apollo Production Server Runner
# Runs the built server with optimized settings for production

set -e

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Check if build exists
if [ ! -d "$PROJECT_ROOT/build" ]; then
  echo "❌ React build not found. Run 'npm run build' first."
  exit 1
fi

if [ ! -d "$PROJECT_ROOT/server/dist" ]; then
  echo "❌ Server build not found. Run 'cd server && npm run build' first."
  exit 1
fi

# Load environment variables if .env exists
if [ -f "$PROJECT_ROOT/.env" ]; then
  export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
fi

# Set production defaults
export NODE_ENV=production
export PORT=${PORT:-3001}
export HOST=${HOST:-0.0.0.0}

echo "Starting Apollo (Production)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Port: $PORT"
echo "Host: $HOST"
echo "DB: ${DATABASE_URL:0:20}..."
echo ""

# Run server
cd "$PROJECT_ROOT"
node server/dist/index.js
