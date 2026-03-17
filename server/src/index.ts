import 'dotenv/config';
console.log('DB URL:', process.env.DATABASE_URL); // add this
import { buildApp } from './app';

const PORT = Number(process.env.PORT ?? 3001);
const HOST = '0.0.0.0';

async function start() {
  const app = await buildApp();
  try {
    await app.listen({ port: PORT, host: HOST });
    console.log(`\nserver running on http://localhost:${PORT}\n`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

start();