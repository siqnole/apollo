"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildApp = buildApp;
const fastify_1 = __importDefault(require("fastify"));
const cors_1 = __importDefault(require("@fastify/cors"));
const cookie_1 = __importDefault(require("@fastify/cookie"));
const jwt_1 = __importDefault(require("@fastify/jwt"));
const static_1 = __importDefault(require("@fastify/static"));
const path_1 = __importDefault(require("path"));
const fs_1 = require("fs");
const bcrypt_1 = __importDefault(require("bcrypt"));
const db_1 = __importDefault(require("./plugins/db"));
const auth_1 = __importDefault(require("./plugins/auth"));
const users_1 = __importDefault(require("./routes/users"));
const auth_2 = __importDefault(require("./routes/auth"));
const problems_1 = __importDefault(require("./routes/problems"));
const sandbox_1 = __importDefault(require("./routes/sandbox"));
const admin_1 = __importDefault(require("./routes/admin"));
const envConfig_1 = require("./utils/envConfig");
function xpToRank(xp) {
    if (xp >= 5000)
        return 'Champion';
    if (xp >= 2000)
        return 'Gladiator';
    if (xp >= 500)
        return 'Contender';
    return 'Explorer';
}
async function buildApp() {
    const app = (0, fastify_1.default)({
        logger: process.env.NODE_ENV === 'production'
            ? true // Simple JSON logging in production
            : { transport: { target: 'pino-pretty', options: { colorize: true } } },
    });
    const clientUrls = (0, envConfig_1.parseUrlList)(process.env.CLIENT_URL, 'http://localhost:3000');
    await app.register(cors_1.default, { origin: clientUrls, credentials: true });
    await app.register(cookie_1.default);
    await app.register(jwt_1.default, { secret: process.env.JWT_SECRET ?? 'dev_secret_change_me', cookie: { cookieName: 'apollo_token', signed: false } });
    await app.register(db_1.default);
    await app.register(auth_1.default);
    await app.register(users_1.default, { prefix: '/api/users' });
    await app.register(auth_2.default);
    await app.register(problems_1.default, { prefix: '/api' });
    await app.register(sandbox_1.default, { prefix: '/api' });
    await app.register(admin_1.default, { prefix: '/api' });
    // Serve static React build
    // From dist/app.js, go up 2 levels to project root, then to build folder
    const buildDir = path_1.default.join(__dirname, '../../build');
    if ((process.env.NODE_ENV === 'production' || process.env.SERVE_STATIC === 'true')) {
        try {
            await fs_1.promises.access(buildDir);
            await app.register(static_1.default, {
                root: buildDir,
                prefix: '/',
            });
            // Serve index.html for client-side routing (SPA fallback)
            app.setNotFoundHandler(async (_req, reply) => {
                reply.sendFile('index.html');
            });
            app.log.info(`Serving static files from ${buildDir}`);
        }
        catch (err) {
            app.log.warn(`Build directory not found at ${buildDir}, skipping static serving`);
        }
    }
    app.post('/api/auth/login', async (req, reply) => {
        const { email, password } = req.body;
        if (!email || !password)
            return reply.status(400).send({ error: 'Email and password required' });
        const result = await app.db.query(`SELECT id, username, xp, password_hash FROM users WHERE email = $1`, [email.toLowerCase()]);
        if (result.rows.length === 0)
            return reply.status(401).send({ error: 'Invalid email or password' });
        const user = result.rows[0];
        if (!user.password_hash)
            return reply.status(401).send({ error: 'This account uses social login' });
        const valid = await bcrypt_1.default.compare(password, user.password_hash);
        if (!valid)
            return reply.status(401).send({ error: 'Invalid email or password' });
        const token = app.jwt.sign({ sub: user.id, username: user.username }, { expiresIn: '30d' });
        reply.setCookie('apollo_token', token, { httpOnly: true, secure: false, sameSite: 'lax', path: '/', maxAge: 60 * 60 * 24 * 30 });
        return reply.send({ user: { id: user.id, username: user.username, rank: xpToRank(user.xp), xp: user.xp }, token });
    });
    app.get('/health', async () => ({ status: 'ok', ts: new Date().toISOString() }));
    return app;
}
