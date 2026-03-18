"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = authRoutes;
const https_1 = __importDefault(require("https"));
const querystring_1 = __importDefault(require("querystring"));
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
function httpsPost(url, data, headers) {
    return new Promise((resolve, reject) => {
        const urlObj = new URL(url);
        const options = {
            hostname: urlObj.hostname,
            path: urlObj.pathname + urlObj.search,
            method: 'POST',
            headers: { 'Content-Length': Buffer.byteLength(data), ...headers },
        };
        const req = https_1.default.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => (body += chunk));
            res.on('end', () => { try {
                resolve(JSON.parse(body));
            }
            catch {
                reject(new Error('Parse error'));
            } });
        });
        req.on('error', reject);
        req.write(data);
        req.end();
    });
}
const serverUrls = (0, envConfig_1.parseUrlList)(process.env.SERVER_URL, 'http://localhost:3001');
const BASE = (0, envConfig_1.getPrimaryUrl)(serverUrls);
const clientUrls = (0, envConfig_1.parseUrlList)(process.env.CLIENT_URL, 'http://localhost:3000');
// OAuth configuration
const OAUTH_CONFIG = {
    github: {
        enabled: !!process.env.GITHUB_CLIENT_ID,
        clientId: process.env.GITHUB_CLIENT_ID,
        clientSecret: process.env.GITHUB_CLIENT_SECRET,
        authorizeUrl: 'https://github.com/login/oauth/authorize',
        tokenUrl: 'https://github.com/login/oauth/access_token',
        userUrl: 'https://api.github.com/user',
        scope: 'read:user',
    },
    google: {
        enabled: !!process.env.GOOGLE_CLIENT_ID,
        clientId: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        authorizeUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
        tokenUrl: 'https://oauth2.googleapis.com/token',
        userUrl: 'https://www.googleapis.com/oauth2/v2/userinfo',
        scope: 'profile email',
    },
    linkedin: {
        enabled: !!process.env.LINKEDIN_CLIENT_ID,
        clientId: process.env.LINKEDIN_CLIENT_ID,
        clientSecret: process.env.LINKEDIN_CLIENT_SECRET,
        authorizeUrl: 'https://www.linkedin.com/oauth/v2/authorization',
        tokenUrl: 'https://www.linkedin.com/oauth/v2/accessToken',
        userUrl: 'https://api.linkedin.com/v2/me',
        scope: 'r_liteprofile r_emailaddress',
    },
    twitter: {
        enabled: !!process.env.TWITTER_CLIENT_ID,
        clientId: process.env.TWITTER_CLIENT_ID,
        clientSecret: process.env.TWITTER_CLIENT_SECRET,
        authorizeUrl: 'https://twitter.com/i/oauth2/authorize',
        tokenUrl: 'https://api.twitter.com/2/oauth2/token',
        userUrl: 'https://api.twitter.com/2/users/me',
        scope: 'tweet.read users.read',
    },
    discord: {
        enabled: !!process.env.DISCORD_CLIENT_ID,
        clientId: process.env.DISCORD_CLIENT_ID,
        clientSecret: process.env.DISCORD_CLIENT_SECRET,
        authorizeUrl: 'https://discord.com/api/oauth2/authorize',
        tokenUrl: 'https://discord.com/api/oauth2/token',
        userUrl: 'https://discord.com/api/users/@me',
        scope: 'identify email',
    },
};
async function authRoutes(fastify) {
    // ── Single consolidated OAuth callback ──────────────────────────────────
    fastify.get('/auth/callback', async (req, reply) => {
        const { code, provider, error } = req.query;
        if (error) {
            return reply.type('text/html').send(popupResponse(provider, false, clientUrls));
        }
        if (!code || !provider) {
            return reply.status(400).send({ error: 'Missing code or provider' });
        }
        const config = OAUTH_CONFIG[provider];
        if (!config || !config.enabled) {
            return reply.type('text/html').send(popupResponse(provider, false, clientUrls));
        }
        try {
            // Exchange code for token
            const tokenData = querystring_1.default.stringify({
                client_id: config.clientId,
                client_secret: config.clientSecret,
                code,
                redirect_uri: `${BASE}/auth/callback?provider=${provider}`,
                grant_type: 'authorization_code',
            });
            const tokenResponse = await httpsPost(config.tokenUrl, tokenData, {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json',
            });
            const accessToken = tokenResponse.access_token;
            if (!accessToken) {
                return reply.type('text/html').send(popupResponse(provider, false, clientUrls));
            }
            // Fetch user info to verify auth
            await httpsGet(config.userUrl, {
                'Authorization': `Bearer ${accessToken}`,
                'User-Agent': 'Apollo',
            });
            // Success!
            return reply.type('text/html').send(popupResponse(provider, true, clientUrls));
        }
        catch (err) {
            const errorMsg = err instanceof Error ? err.message : String(err);
            fastify.log.error(`OAuth callback error for ${provider}: ${errorMsg}`);
            return reply.type('text/html').send(popupResponse(provider, false, clientUrls));
        }
    });
    // ── OAuth start redirects (these redirect to provider authorize endpoints) ────
    const startRedirects = [
        { path: '/auth/github', provider: 'github' },
        { path: '/auth/google', provider: 'google' },
        { path: '/auth/linkedin', provider: 'linkedin' },
        { path: '/auth/twitter', provider: 'twitter' },
        { path: '/auth/discord', provider: 'discord' },
    ];
    for (const { path, provider } of startRedirects) {
        fastify.get(path, async (req, reply) => {
            const config = OAUTH_CONFIG[provider];
            if (!config.enabled) {
                return reply.type('text/html').send(popupResponse(provider, false, clientUrls));
            }
            const params = new URLSearchParams({
                client_id: config.clientId,
                redirect_uri: `${BASE}/auth/callback?provider=${provider}`,
                response_type: 'code',
                scope: config.scope,
            });
            const authorizeUrl = `${config.authorizeUrl}?${params.toString()}`;
            reply.redirect(authorizeUrl);
        });
    }
    // ── Dev.to (manual API key check) ──────────────────────────────────────
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
