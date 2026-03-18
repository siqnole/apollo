#!/bin/bash

# Apollo Dev Runner - Run client + server with split terminal view
# Usage: ./run-dev.sh

set -e

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SESSION_NAME="apollo-dev"

# Kill existing session if it exists
tmux kill-session -t $SESSION_NAME 2>/dev/null || true

# Create new tmux session with 2 panes
tmux new-session -d -s $SESSION_NAME -x 200 -y 50

# Pane 0: Server
tmux send-keys -t $SESSION_NAME:0 "cd $PROJECT_ROOT/server && npm run dev" Enter

# Pane 1: Client
tmux split-window -t $SESSION_NAME:0 -h
tmux send-keys -t $SESSION_NAME:0.1 "cd $PROJECT_ROOT && npm start" Enter

# Set pane widths (roughly 50/50)
tmux select-layout -t $SESSION_NAME:0 even-horizontal

# Attach to session
tmux attach -t $SESSION_NAME
