import 'dotenv/config';
console.log('Starting Apollo...');
console.log('DB URL:', process.env.DATABASE_URL?.substring(0, 40) + '...');
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

    console.log('[INIT] Database URL is set');
    console.log('[INIT] Initializing database...');
    try {
      await initializeDatabase(DATABASE_URL);
      console.log('[INIT] ✅ Database initialization complete');
    } catch (dbErr) {
      console.error('[INIT] ❌ Database initialization failed:');
      console.error(dbErr);
      throw dbErr;
    }

    console.log('[INIT] Building app...');
    const app = await buildApp();
    
    console.log(`[INIT] Listening on ${HOST}:${PORT}...`);
    await app.listen({ port: PORT, host: HOST });
    console.log(`[INIT] ✅ Server running on http://localhost:${PORT}\n`);
  } catch (err) {
    console.error('[INIT] ❌ Failed to start server:');
    console.error(err);
    process.exit(1);
  }
}

start();