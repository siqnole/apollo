import 'dotenv/config';
console.error('[STARTUP] Starting Apollo server...');
console.error('[STARTUP] DB URL:', process.env.DATABASE_URL?.substring(0, 40) + '...');
console.error('[STARTUP] NODE_ENV:', process.env.NODE_ENV);

import { buildApp } from './app';
import { initializeDatabase } from './utils/initializeDb';

const PORT = Number(process.env.PORT ?? 3001);
const HOST = '0.0.0.0';

async function start() {
  try {
    const DATABASE_URL = process.env.DATABASE_URL;
    if (!DATABASE_URL) {
      throw new Error('DATABASE_URL environment variable not set');
    }

    console.error('[DB INIT] Attempting database initialization...');
    
    try {
      await initializeDatabase(DATABASE_URL);
      console.error('[DB INIT] ✅ Database initialization complete');
    } catch (dbErr) {
      console.error('[DB INIT] ⚠️  Database initialization error (continuing anyway):');
      console.error(dbErr);
      // Don't throw - let the server start anyway
    }

    console.error('[APP BUILD] Building Fastify app...');
    const app = await buildApp();
    
    console.error(`[SERVER] Listening on ${HOST}:${PORT}...`);
    await app.listen({ port: PORT, host: HOST });
    console.error(`[SERVER] ✅ Server running on http://${HOST}:${PORT}\n`);
  } catch (err) {
    console.error('[STARTUP] ❌ Fatal error starting server:');
    console.error(err);
    process.exit(1);
  }
}

start().catch((err) => {
  console.error('[STARTUP] Uncaught error in start function:');
  console.error(err);
  process.exit(1);
});