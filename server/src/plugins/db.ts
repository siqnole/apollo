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

  // Verify connection on startup
  try {
    const client: PoolClient = await pool.connect();
    fastify.log.info('PostgreSQL connected');
    client.release();
  } catch (err) {
    fastify.log.error(err instanceof Error ? err : new Error(`PostgreSQL connection failed: ${String(err)}`));
    process.exit(1);
  }

  fastify.decorate('db', pool);

  fastify.addHook('onClose', async () => {
    await pool.end();
    fastify.log.info('PostgreSQL pool closed');
  });
});