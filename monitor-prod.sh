#!/bin/bash

# Apollo Production Monitor & Logger
# Comprehensive terminal UI for monitoring your Apollo server

set -e

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SESSION_NAME="apollo-monitor"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment
if [ -f "$PROJECT_ROOT/.env" ]; then
  export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
fi

export NODE_ENV=production
export PORT=${PORT:-3001}
export HOST=${HOST:-0.0.0.0}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Apollo Monitor${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Port: $PORT"
echo "  Host: $HOST"
echo "  Environment: $NODE_ENV"
echo "  Database: ${DATABASE_URL:0:30}..."
echo ""

# Kill existing session if it exists
tmux kill-session -t $SESSION_NAME 2>/dev/null || true

# Create new tmux session
tmux new-session -d -s $SESSION_NAME -x 200 -y 50

# Bottom pane: Server logs (80% height)
tmux send-keys -t $SESSION_NAME:0 "cd $PROJECT_ROOT && node server/dist/index.js" Enter

# Split top pane for stats
tmux split-window -t $SESSION_NAME:0 -v -l 8
tmux send-keys -t $SESSION_NAME:0.0 "
while true; do
  clear
  echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  echo '📊 Apollo Server Status'
  echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  
  if curl -s http://localhost:$PORT/health > /dev/null 2>&1; then
    echo '✅ Server: Running on localhost:'$PORT
    RESPONSE=\$(curl -s http://localhost:$PORT/health)
    echo \"   Status: \$RESPONSE\"
  else
    echo '❌ Server: Not responding (check logs below)'
  fi
  
  echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  echo 'Commands: q=quit | r=reload | Ctrl+C to stop'
  echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  
  sleep 5
done
" Enter

# Resize panes
tmux resize-pane -t $SESSION_NAME:0.0 -y 8

echo -e "${GREEN}✨ Monitor Dashboard Started${NC}"
echo ""
echo -e "${YELLOW}Tmux Controls:${NC}"
echo "  Ctrl+B then Arrow Keys  - Switch panes"
echo "  Ctrl+B then D           - Detach from session"
echo "  Ctrl+B then :kill-session - Stop all"
echo ""
echo -e "${YELLOW}Keyboard Shortcuts:${NC}"
echo "  q - Quit from dashboard"
echo "  r - Reload dashboard"
echo "  Ctrl+C - Stop server"
echo ""

# Attach to session
tmux attach -t $SESSION_NAME
