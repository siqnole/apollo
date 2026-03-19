# Database Setup

## Local Development

1. **Create and start PostgreSQL database:**
   ```bash
   createdb apollo
   ```

2. **Initialize schema:**
   ```bash
   cd server
   npm run init-db
   ```

## Production (Render.com)

The database is created automatically when you provision a Postgres database on Render. To initialize the schema:

### Option 1: Using Render Dashboard (Recommended)
1. Go to your Postgres database resource
2. Click "Connect"
3. Click "Using psql"
4. Copy the connection command
5. In your terminal, connect to the database
6. Paste the contents of `server/src/db/migrate.sql` into the psql prompt

### Option 2: Using CLI (Requires psql installed locally)
```bash
DATABASE_URL="your-render-postgres-url" npm run init-db
```

### Option 3: From Render deployment
Add this to your `render.yaml` postBuildCommand:
```yaml
services:
  - type: web
    postBuildCommand: "npm install && npm run build && cd server && npm run init-db"
```

## Troubleshooting

If you see: `relation "users" does not exist`
- The database schema hasn't been initialized
- Run `npm run init-db` to set up all tables

If connection fails:
- Verify `DATABASE_URL` environment variable is set correctly
- Check database credentials and network access
- For Render: ensure database is in "Available" state

## Important Tables

The migration script creates:
- `users` - User accounts and authentication
- `problems` - Coding problems and challenges  
- `test_cases` - Test cases for problems
- `submissions` - User problem submissions
- `user_interests` - User interest tags
- `user_goals` - User learning goals
- `social_connections` - OAuth provider links
- `rivals` - User rivalries/connections
- `choices` - Multiple choice options
