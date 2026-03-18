import fp from 'fastify-plugin';
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';

declare module 'fastify' {
  interface FastifyRequest {
    userId: string;
    username: string;
  }
}

export default fp(async (fastify: FastifyInstance) => {
  fastify.decorate(
    'authenticate',
    async (req: FastifyRequest, reply: FastifyReply) => {
      try {
        // Try Authorization header first, then cookie
        const authHeader = req.headers.authorization;
        if (authHeader?.startsWith('Bearer ')) {
          const token = authHeader.slice(7);
          const payload = fastify.jwt.verify<{ sub: string; username: string }>(token);
          req.userId   = payload.sub;
          req.username = payload.username;
          return;
        }

        // Fall back to cookie
        const cookie = req.cookies?.apollo_token;
        if (cookie) {
          const payload = fastify.jwt.verify<{ sub: string; username: string }>(cookie);
          req.userId   = payload.sub;
          req.username = payload.username;
          return;
        }

        return reply.status(401).send({ error: 'Unauthorized' });
      } catch {
        return reply.status(401).send({ error: 'Unauthorized' });
      }
    }
  );
});

  fastify.decorate(
    'authenticateOptional',
    async (req: FastifyRequest, reply: FastifyReply) => {
      try {
        // Try Authorization header first, then cookie
        const authHeader = req.headers.authorization;
        if (authHeader?.startsWith('Bearer ')) {
          const token = authHeader.slice(7);
          const payload = fastify.jwt.verify<{ sub: string; username: string }>(token);
          req.userId   = payload.sub;
          req.username = payload.username;
          return;
        }

        // Fall back to cookie
        const cookie = req.cookies?.apollo_token;
        if (cookie) {
          const payload = fastify.jwt.verify<{ sub: string; username: string }>(cookie);
          req.userId   = payload.sub;
          req.username = payload.username;
          return;
        }
        // If not authenticated, just continue (userId will be undefined)
      } catch {
        // If not authenticated, just continue (userId will be undefined)
      }
    }
  );
});

// Extend FastifyInstance type
declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
    authenticateOptional: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}