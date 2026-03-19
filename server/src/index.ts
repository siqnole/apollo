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

    console.log('Initializing database...');
    await initializeDatabase(DATABASE_URL);

    console.log('Building app...');
    const app = await buildApp();
    
    console.log(`Listening on ${HOST}:${PORT}...`);
    await app.listen({ port: PORT, host: HOST });
    console.log(`\nrunning on http://localhost:${PORT}\n`);
  } catch (err) {
    console.error('failed to start server:', err);
    process.exit(1);
  }
}

start();