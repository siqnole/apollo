#!/bin/bash

# Apollo Render Logs Dashboard
# View logs from your deployed Render service

set -e

# Check if render CLI is installed
if ! command -v render &> /dev/null; then
  echo "❌ Render CLI not found. Install it: npm install -g @RenderedText/render-cli"
  echo "   Or visit: https://render.com/docs/api"
  exit 1
fi

SERVICE_NAME="apollo"
LOG_LINES=${1:-100}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Apollo Render"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Service: $SERVICE_NAME"
echo "Lines: $LOG_LINES"
echo ""

# Get latest logs (requires render CLI auth)
# For now, show a helpful guide
echo "To view live logs from Render:"
echo ""
echo "Option 1: Visit Dashboard"
echo "  https://dashboard.render.com/services"
echo ""
echo "Option 2: Use Render CLI"
echo "  render logs --service $SERVICE_NAME"
echo ""
echo "Option 3: Use curl with API key"
echo "  curl -H 'Authorization: Bearer YOUR_API_KEY' \\"
echo "    https://api.render.com/v1/services/$SERVICE_NAME/logs"
echo ""
