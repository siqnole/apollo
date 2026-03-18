# Apollo Scripts
*for my sake*

Quick start scripts for Apollo development and production monitoring.

## Development

### Run Dev (Split Terminal)
```bash
npm run dev
# or
./run-dev.sh
```
Launches a split terminal view with:
- **Left pane**: Server (Node.js backend)
- **Right pane**: Client (React frontend)

Both run in parallel with live logs visible. Perfect for development.

**Tmux Controls:**
- `Ctrl+B` then `Arrow Keys` - Switch between panes
- `Ctrl+B` then `D` - Detach (keeps running)
- `Ctrl+B` then `X` - Kill current pane
- `Ctrl+B` then `:kill-session` - Stop everything

---

## Production

### 1. Run Production Build
```bash
npm run prod
# or
./run-prod.sh
```

**Requirements:**
- `npm run build` - Must build React app first
- `cd server && npm run build` - Must build TypeScript backend first

Runs the production-optimized server with:
- JSON logging (fast, minimal overhead)
- Database retry logic
- Static React app serving

### 2. Monitor Dashboard
```bash
npm run monitor
# or
./monitor-prod.sh
```

Launches a production monitoring dashboard with:
- **Top pane**: Status dashboard (health checks, config)
  - Updates every 5 seconds
  - Shows health endpoint response
- **Bottom pane**: Live server logs
  - All application output in one place
  - Database connection status
  - Error tracking

**Monitors:**
- Server health (`/health` endpoint)
- Port and configuration
- Database connectivity
- Real-time logs

**Tmux Controls (same as dev):**
- `Ctrl+B` then `Arrow Keys` - Switch panes
- `Ctrl+B` then `D` - Detach session
- `Ctrl+B` then `:kill-session` - Stop monitoring

---

## Deployed (Render)

### View Production Logs
```bash
npm run logs
# or
./logs-prod.sh
```

Shows methods to view logs from your deployed Render service:
1. Dashboard website
2. Render CLI
3. Curl with API key

---

## Quick Reference

| Command | Use Case |
|---------|----------|
| `npm run dev` | Local development with split panes |
| `npm run prod` | Run production build locally |
| `npm run monitor` | Monitor running production server |
| `npm run logs` | View Render deployment logs |

---

## Setup One-Time

Make scripts executable:
```bash
chmod +x run-dev.sh run-prod.sh monitor-prod.sh logs-prod.sh
```

Install tmux (if not present):
```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt install tmux

# Alpine (Docker)
apk add tmux
```

---

## Building Before Running

**Before `npm run prod` or `npm run monitor`:**

```bash
# Build React client
npm run build

# Build TypeScript server
cd server && npm run build && cd ..
```

Or use one command:
```bash
npm run build && cd server && npm run build && cd ..
```

---

## Troubleshooting

### "tmux not found"
Install tmux (see Setup One-Time above)

### "Port 3001 already in use"
```bash
# Find and kill process using port 3001
lsof -i :3001 | grep -v PID | awk '{print $2}' | xargs kill -9
```

### Server won't start
Check `.env` file has `DATABASE_URL` and other required vars:
```bash
cat .env
```

### Health check failing
The `/health` endpoint might not be responding. Check server logs in the monitor dashboard.

---

## Environment Variables

These scripts load from `.env` file:

```env
NODE_ENV=production
PORT=3001
HOST=0.0.0.0
DATABASE_URL=postgresql://user:pass@host/db
JWT_SECRET=your-secret-here
CLIENT_URL=http://localhost:3000
SERVER_URL=http://localhost:3001
SERVE_STATIC=true
```
