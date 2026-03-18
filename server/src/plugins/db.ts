import 'dotenv/config';  // must be first line
import fp from 'fastify-plugin';
import { FastifyInstance } from 'fastify';
import { Pool, PoolClient } from 'pg';

declare module 'fastify' {
  interface FastifyInstance {
    db: Pool;
  }
}

export default fp(async (fastify: FastifyInstance) => {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });

  // Verify connection on startup with retries for free tier reliability
  const maxRetries = 5;
  let lastErr: Error | null = null;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const client: PoolClient = await pool.connect();
      fastify.log.info('PostgreSQL connected');
      client.release();
      lastErr = null;
      break;
    } catch (err) {
      lastErr = err instanceof Error ? err : new Error(`PostgreSQL connection failed: ${String(err)}`);
      if (attempt < maxRetries) {
        fastify.log.warn(`Connection attempt ${attempt}/${maxRetries} failed, retrying in ${attempt}s...`);
        await new Promise(r => setTimeout(r, attempt * 1000));
      }
    }
  }

  if (lastErr) {
    fastify.log.error(lastErr);
    process.exit(1);
  }

  fastify.decorate('db', pool);

  fastify.addHook('onClose', async () => {
    await pool.end();
    fastify.log.info('PostgreSQL pool closed');
  });
});