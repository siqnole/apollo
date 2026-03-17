import Fastify from 'fastify';
import cors from '@fastify/cors';
import cookie from '@fastify/cookie';
import jwt from '@fastify/jwt';
import bcrypt from 'bcrypt';
import dbPlugin from './plugins/db';
import authPlugin from './plugins/auth';
import userRoutes from './routes/users';
import authRoutes from './routes/auth';
import problemRoutes from './routes/problems';
import sandboxRoutes from './routes/sandbox';
import adminRoutes   from './routes/admin';

function xpToRank(xp: number): string {
  if (xp >= 5000) return 'Champion';
  if (xp >= 2000) return 'Gladiator';
  if (xp >= 500)  return 'Contender';
  return 'Explorer';
}

export async function buildApp() {
  const app = Fastify({
    logger: { transport: { target: 'pino-pretty', options: { colorize: true } } },
  });

  await app.register(cors, { origin: process.env.CLIENT_URL ?? 'http://localhost:3000', credentials: true });
  await app.register(cookie);
  await app.register(jwt, { secret: process.env.JWT_SECRET ?? 'dev_secret_change_me', cookie: { cookieName: 'apollo_token', signed: false } });
  await app.register(dbPlugin);
  await app.register(authPlugin);
  await app.register(userRoutes,    { prefix: '/api/users' });
  await app.register(authRoutes);
  await app.register(problemRoutes, { prefix: '/api' });
  await app.register(sandboxRoutes, { prefix: '/api' });
  await app.register(adminRoutes,   { prefix: '/api' });

  app.post('/api/auth/login', async (req, reply) => {
    const { email, password } = req.body as { email: string; password: string };
    if (!email || !password) return reply.status(400).send({ error: 'Email and password required' });
    const result = await app.db.query(`SELECT id, username, xp, password_hash FROM users WHERE email = $1`, [email.toLowerCase()]);
    if (result.rows.length === 0) return reply.status(401).send({ error: 'Invalid email or password' });
    const user = result.rows[0];
    if (!user.password_hash) return reply.status(401).send({ error: 'This account uses social login' });
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return reply.status(401).send({ error: 'Invalid email or password' });
    const token = app.jwt.sign({ sub: user.id, username: user.username }, { expiresIn: '30d' });
    reply.setCookie('apollo_token', token, { httpOnly: true, secure: false, sameSite: 'lax', path: '/', maxAge: 60 * 60 * 24 * 30 });
    return reply.send({ user: { id: user.id, username: user.username, rank: xpToRank(user.xp), xp: user.xp }, token });
  });

  app.get('/health', async () => ({ status: 'ok', ts: new Date().toISOString() }));
  return app;
}