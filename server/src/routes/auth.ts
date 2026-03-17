import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import oauth2, { OAuth2Namespace } from '@fastify/oauth2';
import https from 'https';

function popupResponse(platform: string, success: boolean): string {
  const payload = success
    ? JSON.stringify({ type: 'oauth_success', platform })
    : JSON.stringify({ type: 'oauth_error', platform });
  return `<!DOCTYPE html><html><head><title>Apollo OAuth</title></head><body>
<script>
  if (window.opener) window.opener.postMessage(${payload}, '${process.env.CLIENT_URL}');
  window.close();
</script></body></html>`;
}

function httpsGet(url: string, headers: Record<string, string>): Promise<any> {
  return new Promise((resolve, reject) => {
    https.get(url, { headers }, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => { try { resolve(JSON.parse(data)); } catch { reject(new Error('Parse error')); } });
    }).on('error', reject);
  });
}

const BASE = process.env.SERVER_URL ?? 'http://localhost:3001';

export default async function authRoutes(fastify: FastifyInstance) {

  // ── GitHub ────────────────────────────────────────────────────────────
  if (process.env.GITHUB_CLIENT_ID && process.env.GITHUB_CLIENT_SECRET) {
    await fastify.register(oauth2, {
      name:        'githubOAuth2' as keyof FastifyInstance,
      scope:       ['read:user'],
      credentials: {
        client: { id: process.env.GITHUB_CLIENT_ID, secret: process.env.GITHUB_CLIENT_SECRET },
        auth:   oauth2.GITHUB_CONFIGURATION,
      },
      startRedirectPath: '/auth/github',
      callbackUri:       `${BASE}/auth/github/callback`,
    });
    fastify.get('/auth/github/callback', async (req: FastifyRequest, reply: FastifyReply) => {
      try {
        await (fastify as any).githubOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
        return reply.type('text/html').send(popupResponse('gh', true));
      } catch { return reply.type('text/html').send(popupResponse('gh', false)); }
    });
  } else {
    fastify.get('/auth/github',          async (_req, reply) => reply.type('text/html').send(popupResponse('gh', false)));
    fastify.get('/auth/github/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('gh', false)));
  }

  // ── LinkedIn ──────────────────────────────────────────────────────────
  if (process.env.LINKEDIN_CLIENT_ID && process.env.LINKEDIN_CLIENT_SECRET) {
    await fastify.register(oauth2, {
      name:        'linkedinOAuth2' as keyof FastifyInstance,
      scope:       ['r_liteprofile', 'r_emailaddress'],
      credentials: {
        client: { id: process.env.LINKEDIN_CLIENT_ID, secret: process.env.LINKEDIN_CLIENT_SECRET },
        auth: {
          authorizeHost: 'https://www.linkedin.com', authorizePath: '/oauth/v2/authorization',
          tokenHost:     'https://www.linkedin.com', tokenPath:     '/oauth/v2/accessToken',
        },
      },
      startRedirectPath: '/auth/linkedin',
      callbackUri:       `${BASE}/auth/linkedin/callback`,
    });
    fastify.get('/auth/linkedin/callback', async (req: FastifyRequest, reply: FastifyReply) => {
      try {
        await (fastify as any).linkedinOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
        return reply.type('text/html').send(popupResponse('li', true));
      } catch { return reply.type('text/html').send(popupResponse('li', false)); }
    });
  } else {
    fastify.get('/auth/linkedin',          async (_req, reply) => reply.type('text/html').send(popupResponse('li', false)));
    fastify.get('/auth/linkedin/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('li', false)));
  }

  // ── Twitter ───────────────────────────────────────────────────────────
  if (process.env.TWITTER_CLIENT_ID && process.env.TWITTER_CLIENT_SECRET) {
    await fastify.register(oauth2, {
      name:        'twitterOAuth2' as keyof FastifyInstance,
      scope:       ['tweet.read', 'users.read'],
      credentials: {
        client: { id: process.env.TWITTER_CLIENT_ID, secret: process.env.TWITTER_CLIENT_SECRET },
        auth: {
          authorizeHost: 'https://twitter.com',    authorizePath: '/i/oauth2/authorize',
          tokenHost:     'https://api.twitter.com', tokenPath:    '/2/oauth2/token',
        },
      },
      startRedirectPath: '/auth/twitter',
      callbackUri:       `${BASE}/auth/twitter/callback`,
      pkce:              'S256',
    });
    fastify.get('/auth/twitter/callback', async (req: FastifyRequest, reply: FastifyReply) => {
      try {
        await (fastify as any).twitterOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
        return reply.type('text/html').send(popupResponse('tw', true));
      } catch { return reply.type('text/html').send(popupResponse('tw', false)); }
    });
  } else {
    fastify.get('/auth/twitter',          async (_req, reply) => reply.type('text/html').send(popupResponse('tw', false)));
    fastify.get('/auth/twitter/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('tw', false)));
  }

  // ── Google ────────────────────────────────────────────────────────────
  if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
    await fastify.register(oauth2, {
      name:        'googleOAuth2' as keyof FastifyInstance,
      scope:       ['profile', 'email'],
      credentials: {
        client: { id: process.env.GOOGLE_CLIENT_ID, secret: process.env.GOOGLE_CLIENT_SECRET },
        auth:   oauth2.GOOGLE_CONFIGURATION,
      },
      startRedirectPath: '/auth/google',
      callbackUri:       `${BASE}/auth/google/callback`,
    });
    fastify.get('/auth/google/callback', async (req: FastifyRequest, reply: FastifyReply) => {
      try {
        await (fastify as any).googleOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
        return reply.type('text/html').send(popupResponse('google', true));
      } catch { return reply.type('text/html').send(popupResponse('google', false)); }
    });
  } else {
    fastify.get('/auth/google',          async (_req, reply) => reply.type('text/html').send(popupResponse('google', false)));
    fastify.get('/auth/google/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('google', false)));
  }

  // ── Dev.to ────────────────────────────────────────────────────────────
  fastify.get('/auth/devto', async (_req: FastifyRequest, reply: FastifyReply) => {
    if (process.env.DEVTO_API_KEY) {
      try {
        await httpsGet('https://dev.to/api/users/me', { 'api-key': process.env.DEVTO_API_KEY });
        return reply.type('text/html').send(popupResponse('dev', true));
      } catch { /* fall through */ }
    }
    return reply.type('text/html').send(popupResponse('dev', false));
  });
}