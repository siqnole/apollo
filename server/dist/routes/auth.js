"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = authRoutes;
const oauth2_1 = __importDefault(require("@fastify/oauth2"));
const https_1 = __importDefault(require("https"));
const envConfig_1 = require("../utils/envConfig");
function popupResponse(platform, success, clientUrls) {
    const primaryClientUrl = (0, envConfig_1.getPrimaryUrl)(clientUrls);
    const payload = success
        ? JSON.stringify({ type: 'oauth_success', platform })
        : JSON.stringify({ type: 'oauth_error', platform });
    return `<!DOCTYPE html><html><head><title>Apollo OAuth</title></head><body>
<script>
  if (window.opener) window.opener.postMessage(${payload}, '${primaryClientUrl}');
  window.close();
</script></body></html>`;
}
function httpsGet(url, headers) {
    return new Promise((resolve, reject) => {
        https_1.default.get(url, { headers }, (res) => {
            let data = '';
            res.on('data', (chunk) => (data += chunk));
            res.on('end', () => { try {
                resolve(JSON.parse(data));
            }
            catch {
                reject(new Error('Parse error'));
            } });
        }).on('error', reject);
    });
}
const serverUrls = (0, envConfig_1.parseUrlList)(process.env.SERVER_URL, 'http://localhost:3001');
const BASE = (0, envConfig_1.getPrimaryUrl)(serverUrls);
const clientUrls = (0, envConfig_1.parseUrlList)(process.env.CLIENT_URL, 'http://localhost:3000');
async function authRoutes(fastify) {
    // ── GitHub ────────────────────────────────────────────────────────────
    if (process.env.GITHUB_CLIENT_ID && process.env.GITHUB_CLIENT_SECRET) {
        await fastify.register(oauth2_1.default, {
            name: 'githubOAuth2',
            scope: ['read:user'],
            credentials: {
                client: { id: process.env.GITHUB_CLIENT_ID, secret: process.env.GITHUB_CLIENT_SECRET },
                auth: oauth2_1.default.GITHUB_CONFIGURATION,
            },
            startRedirectPath: '/auth/github',
            callbackUri: `${BASE}/auth/github/callback`,
        });
        fastify.get('/auth/github/callback', async (req, reply) => {
            try {
                await fastify.githubOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
                return reply.type('text/html').send(popupResponse('gh', true, clientUrls));
            }
            catch {
                return reply.type('text/html').send(popupResponse('gh', false, clientUrls));
            }
        });
    }
    else {
        fastify.get('/auth/github', async (_req, reply) => reply.type('text/html').send(popupResponse('gh', false, clientUrls)));
        fastify.get('/auth/github/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('gh', false, clientUrls)));
    }
    // ── LinkedIn ──────────────────────────────────────────────────────────
    if (process.env.LINKEDIN_CLIENT_ID && process.env.LINKEDIN_CLIENT_SECRET) {
        await fastify.register(oauth2_1.default, {
            name: 'linkedinOAuth2',
            scope: ['r_liteprofile', 'r_emailaddress'],
            credentials: {
                client: { id: process.env.LINKEDIN_CLIENT_ID, secret: process.env.LINKEDIN_CLIENT_SECRET },
                auth: {
                    authorizeHost: 'https://www.linkedin.com', authorizePath: '/oauth/v2/authorization',
                    tokenHost: 'https://www.linkedin.com', tokenPath: '/oauth/v2/accessToken',
                },
            },
            startRedirectPath: '/auth/linkedin',
            callbackUri: `${BASE}/auth/linkedin/callback`,
        });
        fastify.get('/auth/linkedin/callback', async (req, reply) => {
            try {
                await fastify.linkedinOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
                return reply.type('text/html').send(popupResponse('li', true, clientUrls));
            }
            catch {
                return reply.type('text/html').send(popupResponse('li', false, clientUrls));
            }
        });
    }
    else {
        fastify.get('/auth/linkedin', async (_req, reply) => reply.type('text/html').send(popupResponse('li', false, clientUrls)));
        fastify.get('/auth/linkedin/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('li', false, clientUrls)));
    }
    // ── Twitter ───────────────────────────────────────────────────────────
    if (process.env.TWITTER_CLIENT_ID && process.env.TWITTER_CLIENT_SECRET) {
        await fastify.register(oauth2_1.default, {
            name: 'twitterOAuth2',
            scope: ['tweet.read', 'users.read'],
            credentials: {
                client: { id: process.env.TWITTER_CLIENT_ID, secret: process.env.TWITTER_CLIENT_SECRET },
                auth: {
                    authorizeHost: 'https://twitter.com', authorizePath: '/i/oauth2/authorize',
                    tokenHost: 'https://api.twitter.com', tokenPath: '/2/oauth2/token',
                },
            },
            startRedirectPath: '/auth/twitter',
            callbackUri: `${BASE}/auth/twitter/callback`,
            pkce: 'S256',
        });
        fastify.get('/auth/twitter/callback', async (req, reply) => {
            try {
                await fastify.twitterOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
                return reply.type('text/html').send(popupResponse('tw', true, clientUrls));
            }
            catch {
                return reply.type('text/html').send(popupResponse('tw', false, clientUrls));
            }
        });
    }
    else {
        fastify.get('/auth/twitter', async (_req, reply) => reply.type('text/html').send(popupResponse('tw', false, clientUrls)));
        fastify.get('/auth/twitter/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('tw', false, clientUrls)));
    }
    // ── Google ────────────────────────────────────────────────────────────
    if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
        await fastify.register(oauth2_1.default, {
            name: 'googleOAuth2',
            scope: ['profile', 'email'],
            credentials: {
                client: { id: process.env.GOOGLE_CLIENT_ID, secret: process.env.GOOGLE_CLIENT_SECRET },
                auth: oauth2_1.default.GOOGLE_CONFIGURATION,
            },
            startRedirectPath: '/auth/google',
            callbackUri: `${BASE}/auth/google/callback`,
        });
        fastify.get('/auth/google/callback', async (req, reply) => {
            try {
                await fastify.googleOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
                return reply.type('text/html').send(popupResponse('google', true, clientUrls));
            }
            catch {
                return reply.type('text/html').send(popupResponse('google', false, clientUrls));
            }
        });
    }
    else {
        fastify.get('/auth/google', async (_req, reply) => reply.type('text/html').send(popupResponse('google', false, clientUrls)));
        fastify.get('/auth/google/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('google', false, clientUrls)));
    }
    // ── Discord ──────────────────────────────────────────────────────
    if (process.env.DISCORD_CLIENT_ID && process.env.DISCORD_CLIENT_SECRET) {
        await fastify.register(oauth2_1.default, {
            name: 'discordOAuth2',
            scope: ['identify', 'email'],
            credentials: {
                client: { id: process.env.DISCORD_CLIENT_ID, secret: process.env.DISCORD_CLIENT_SECRET },
                auth: {
                    authorizeHost: 'https://discord.com', authorizePath: '/api/oauth2/authorize',
                    tokenHost: 'https://discord.com', tokenPath: '/api/oauth2/token',
                },
            },
            startRedirectPath: '/auth/discord',
            callbackUri: `${BASE}/auth/discord/callback`,
        });
        fastify.get('/auth/discord/callback', async (req, reply) => {
            try {
                await fastify.discordOAuth2.getAccessTokenFromAuthorizationCodeFlow(req);
                return reply.type('text/html').send(popupResponse('discord', true, clientUrls));
            }
            catch {
                return reply.type('text/html').send(popupResponse('discord', false, clientUrls));
            }
        });
    }
    else {
        fastify.get('/auth/discord', async (_req, reply) => reply.type('text/html').send(popupResponse('discord', false, clientUrls)));
        fastify.get('/auth/discord/callback', async (_req, reply) => reply.type('text/html').send(popupResponse('discord', false, clientUrls)));
    }
    // ── Dev.to ────────────────────────────────────────────────────────────
    fastify.get('/auth/devto', async (_req, reply) => {
        if (process.env.DEVTO_API_KEY) {
            try {
                await httpsGet('https://dev.to/api/users/me', { 'api-key': process.env.DEVTO_API_KEY });
                return reply.type('text/html').send(popupResponse('dev', true, clientUrls));
            }
            catch { /* fall through */ }
        }
        return reply.type('text/html').send(popupResponse('dev', false, clientUrls));
    });
}
