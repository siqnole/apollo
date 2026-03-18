import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;

// ── XP → Rank ──────────────────────────────────────────────────────────────
function xpToRank(xp: number): string {
  if (xp >= 5000) return 'Champion';
  if (xp >= 2000) return 'Gladiator';
  if (xp >= 500)  return 'Contender';
  return 'Explorer';
}


// ── Solved stats ───────────────────────────────────────────────────────────
async function getSolvedStats(db: FastifyInstance['db'], userId: string) {
  const result = await db.query(
    `SELECT p.difficulty, p.problem_type, COUNT(DISTINCT s.problem_id) AS cnt
     FROM submissions s
     JOIN problems p ON p.id = s.problem_id
     WHERE s.user_id = $1 AND s.status = 'accepted'
     GROUP BY p.difficulty, p.problem_type`,
    [userId]
  );
  const byDiff: Record<string, number> = {};
  const byType: Record<string, number> = {};
  let total = 0;
  for (const row of result.rows) {
    const n = Number(row.cnt);
    byDiff[row.difficulty] = (byDiff[row.difficulty] ?? 0) + n;
    byType[row.problem_type] = (byType[row.problem_type] ?? 0) + n;
    total += n;
  }
  return { solved_by_difficulty: byDiff, solved_by_type: byType, problems_solved: total };
}

interface OnboardBody {
  email:      string;
  password:   string;
  username:   string;
  niche?:     string;
  bio?:       string;
  interests:  string[];
  skill_tier: string;   // chosen during onboarding, used for rival matching
  goals:      string[];
  socials?:   Record<string, boolean>;
}

interface LoginBody {
  email:    string;
  password: string;
}

async function findRivals(
  db: FastifyInstance['db'],
  userId: string,
  skillTier: string,
  interests: string[]
): Promise<number> {
  if (interests.length === 0) return 0;
  const placeholders = interests.map((_, i) => `$${i + 3}`).join(', ');
  const result = await db.query(
    `SELECT u.id, COUNT(ui.interest) AS shared
     FROM users u
     JOIN user_interests ui ON ui.user_id = u.id
     WHERE u.id != $1
       AND u.skill_tier = $2
       AND ui.interest IN (${placeholders})
     GROUP BY u.id
     ORDER BY shared DESC
     LIMIT 5`,
    [userId, skillTier, ...interests]
  );
  for (const row of result.rows) {
    const [a, b] = [userId, row.id].sort();
    await db.query(
      `INSERT INTO rivals (user_a, user_b) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
      [a, b]
    );
  }
  return result.rows.length;
}

function setAuthCookie(reply: FastifyReply, token: string) {
  reply.setCookie('apollo_token', token, {
    httpOnly: true, secure: false, sameSite: 'lax', path: '/', maxAge: 60 * 60 * 24 * 30,
  });
}

export default async function userRoutes(fastify: FastifyInstance) {

  // ── GET /api/users/check-username ────────────────────────────────────────
  fastify.get(
    '/check-username',
    async (req: FastifyRequest<{ Querystring: { username: string } }>, reply: FastifyReply) => {
      const { username } = req.query;
      if (!username || username.length < 3) return reply.send({ available: false });
      const result = await fastify.db.query(
        'SELECT id FROM users WHERE username = $1', [username.toLowerCase()]
      );
      return reply.send({ available: result.rows.length === 0 });
    }
  );

  // ── POST /api/users/onboard ──────────────────────────────────────────────
  fastify.post(
    '/onboard',
    async (req: FastifyRequest<{ Body: OnboardBody }>, reply: FastifyReply) => {
      const { email, password, username, niche, bio, skill_tier, interests, goals, socials } = req.body;

      // Accept both 'level' and 'skill_tier' from frontend during transition
      const tier = skill_tier ?? (req.body as any).level;

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
        return reply.status(400).send({ error: 'Valid email required' });
      if (!password || password.length < 8)
        return reply.status(400).send({ error: 'Password must be at least 8 characters' });
      if (!username || username.length < 3 || username.length > 20)
        return reply.status(400).send({ error: 'Invalid username' });
      if (!/^[a-zA-Z0-9_]+$/.test(username))
        return reply.status(400).send({ error: 'Username: letters, numbers, underscores only' });
      if (!tier)
        return reply.status(400).send({ error: 'Skill tier is required' });
      if (!interests || interests.length < 3)
        return reply.status(400).send({ error: 'At least 3 interests required' });

      const client = await fastify.db.connect();
      try {
        await client.query('BEGIN');

        const emailCheck = await client.query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
        if (emailCheck.rows.length > 0) {
          await client.query('ROLLBACK');
          return reply.status(409).send({ error: 'Email already registered' });
        }
        const userCheck = await client.query('SELECT id FROM users WHERE username = $1', [username.toLowerCase()]);
        if (userCheck.rows.length > 0) {
          await client.query('ROLLBACK');
          return reply.status(409).send({ error: 'Username already taken' });
        }

        const password_hash = await bcrypt.hash(password, SALT_ROUNDS);

        const userResult = await client.query(
          `INSERT INTO users (email, password_hash, username, niche, bio, skill_tier, xp)
           VALUES ($1, $2, $3, $4, $5, $6, 0)
           RETURNING id, username, skill_tier, xp`,
          [email.toLowerCase(), password_hash, username.toLowerCase(), niche ?? null, bio ?? null, tier]
        );
        const user = userResult.rows[0];

        for (const interest of interests)
          await client.query('INSERT INTO user_interests (user_id, interest) VALUES ($1, $2)', [user.id, interest]);
        for (const goal of (goals ?? []))
          await client.query('INSERT INTO user_goals (user_id, goal) VALUES ($1, $2)', [user.id, goal]);
        if (socials) {
          for (const [platform, connected] of Object.entries(socials)) {
            if (connected) await client.query(
              `INSERT INTO social_connections (user_id, platform, connected) VALUES ($1, $2, $3)
               ON CONFLICT (user_id, platform) DO UPDATE SET connected = $3`,
              [user.id, platform, connected]
            );
          }
        }

        await client.query('COMMIT');

        const matchedRivals = await findRivals(fastify.db, user.id, tier, interests);
        const token = fastify.jwt.sign({ sub: user.id, username: user.username }, { expiresIn: '30d' });
        setAuthCookie(reply, token);

        return reply.status(201).send({
          user: {
            id: user.id, username: user.username,
            rank: xpToRank(0),   // always Explorer on signup
            xp: 0, matchedRivals,
          },
          token,
        });

      } catch (err) {
        await client.query('ROLLBACK');
        fastify.log.error(err);
        return reply.status(500).send({ error: 'Internal server error' });
      } finally {
        client.release();
      }
    }
  );

  // ── POST /api/users/login (also registered in app.ts) ───────────────────
  fastify.post(
    '/login',
    async (req: FastifyRequest<{ Body: LoginBody }>, reply: FastifyReply) => {
      const { email, password } = req.body;
      if (!email || !password) return reply.status(400).send({ error: 'Email and password required' });

      const result = await fastify.db.query(
        `SELECT id, username, skill_tier, xp, password_hash FROM users WHERE email = $1`,
        [email.toLowerCase()]
      );
      if (result.rows.length === 0) return reply.status(401).send({ error: 'Invalid email or password' });
      const user = result.rows[0];
      if (!user.password_hash) return reply.status(401).send({ error: 'This account uses social login' });

      const valid = await bcrypt.compare(password, user.password_hash);
      if (!valid) return reply.status(401).send({ error: 'Invalid email or password' });

      const token = fastify.jwt.sign({ sub: user.id, username: user.username }, { expiresIn: '30d' });
      setAuthCookie(reply, token);
      return reply.send({
        user: { id: user.id, username: user.username, rank: xpToRank(user.xp), xp: user.xp },
        token,
      });
    }
  );

  // ── GET /api/users/me ────────────────────────────────────────────────────
  fastify.get(
    '/me',
    { preHandler: [fastify.authenticate] },
    async (req: FastifyRequest, reply: FastifyReply) => {
      const { userId } = req;
      const userResult = await fastify.db.query(
        `SELECT id, username, niche, bio, skill_tier, xp, created_at FROM users WHERE id = $1`, [userId]
      );
      if (userResult.rows.length === 0) return reply.status(404).send({ error: 'User not found' });
      const user = userResult.rows[0];

      const [interests, goals, socials, rivalCount, solvedStats] = await Promise.all([
        fastify.db.query(`SELECT interest FROM user_interests WHERE user_id = $1`, [userId]),
        fastify.db.query(`SELECT goal FROM user_goals WHERE user_id = $1`, [userId]),
        fastify.db.query(`SELECT platform, connected, profile_url FROM social_connections WHERE user_id = $1`, [userId]),
        fastify.db.query(`SELECT COUNT(*) FROM rivals WHERE user_a = $1 OR user_b = $1`, [userId]),
        getSolvedStats(fastify.db, userId),
      ]);

      return reply.send({
        ...user,
        rank:                xpToRank(user.xp),
        interests:           interests.rows.map((r: { interest: string }) => r.interest),
        goals:               goals.rows.map((r: { goal: string }) => r.goal),
        socials:             socials.rows,
        rivalCount:          Number(rivalCount.rows[0].count),
        problems_solved:     solvedStats.problems_solved,
        solved_by_difficulty: solvedStats.solved_by_difficulty,
        solved_by_type:      solvedStats.solved_by_type,
      });
    }
  );

  // ── GET /api/users/rivals ────────────────────────────────────────────────
  fastify.get(
    '/rivals',
    { preHandler: [fastify.authenticate] },
    async (req: FastifyRequest, reply: FastifyReply) => {
      const { userId } = req;
      const result = await fastify.db.query(
        `SELECT
           u.id, u.username, u.skill_tier, u.xp, u.niche,
           array_agg(DISTINCT ui.interest) FILTER (WHERE ui.interest IS NOT NULL) AS interests
         FROM rivals r
         JOIN users u ON (CASE WHEN r.user_a = $1 THEN r.user_b ELSE r.user_a END = u.id)
         LEFT JOIN user_interests ui ON ui.user_id = u.id
         WHERE r.user_a = $1 OR r.user_b = $1
         GROUP BY u.id
         ORDER BY u.xp DESC`,
        [userId]
      );
      // Attach computed rank to each rival
      const rivals = result.rows.map((r: any) => ({
        ...r,
        interests: Array.isArray(r.interests) ? r.interests.filter(Boolean) : [],
        rank: xpToRank(r.xp)
      }));
      return reply.send({ rivals });
    }
  );

  // ── POST /api/users/xp ───────────────────────────────────────────────────
  // Body: { delta: number, reason?: string }
  // delta > 0 adds XP, delta < 0 removes XP (floors at 0)
  fastify.post(
    '/xp',
    { preHandler: [fastify.authenticate] },
    async (req: FastifyRequest, reply: FastifyReply) => {
      const { userId } = req;
      const { delta, reason } = req.body as { delta: number; reason?: string };

      if (typeof delta !== 'number' || isNaN(delta)) {
        return reply.status(400).send({ error: 'delta must be a number' });
      }
      if (delta === 0) {
        return reply.status(400).send({ error: 'delta cannot be zero' });
      }
      if (Math.abs(delta) > 10000) {
        return reply.status(400).send({ error: 'delta cannot exceed ±10000 in a single call' });
      }

      const result = await fastify.db.query(
        `UPDATE users
         SET xp = GREATEST(0, xp + $1)
         WHERE id = $2
         RETURNING xp`,
        [Math.round(delta), userId]
      );

      if (result.rows.length === 0) {
        return reply.status(404).send({ error: 'User not found' });
      }

      const newXp   = result.rows[0].xp;
      const newRank = xpToRank(newXp);

      fastify.log.info(
        { userId, delta, reason: reason ?? 'unspecified', newXp, newRank },
        'XP updated'
      );

      return reply.send({ xp: newXp, rank: newRank, delta: Math.round(delta) });
    }
  );

  // ── PATCH /api/users/me ──────────────────────────────────────────────────
  fastify.patch(
    '/me',
    { preHandler: [fastify.authenticate] },
    async (req: FastifyRequest, reply: FastifyReply) => {
      const { userId } = req;
      const {
        username, niche, bio, skill_tier, interests, goals,
      } = req.body as {
        username?:   string;
        niche?:      string;
        bio?:        string;
        skill_tier?: string;
        interests?:  string[];
        goals?:      string[];
      };

      const client = await fastify.db.connect();
      try {
        await client.query('BEGIN');

        // Username uniqueness check if changing
        if (username) {
          if (!/^[a-zA-Z0-9_]+$/.test(username) || username.length < 3 || username.length > 20) {
            return reply.status(400).send({ error: 'Invalid username' });
          }
          const clash = await client.query(
            'SELECT id FROM users WHERE username = $1 AND id != $2',
            [username.toLowerCase(), userId]
          );
          if (clash.rows.length > 0) {
            await client.query('ROLLBACK');
            return reply.status(409).send({ error: 'Username already taken' });
          }
        }

        await client.query(
          `UPDATE users SET
             username   = COALESCE($1, username),
             niche      = COALESCE($2, niche),
             bio        = COALESCE($3, bio),
             skill_tier = COALESCE($4, skill_tier)
           WHERE id = $5`,
          [username?.toLowerCase() ?? null, niche ?? null, bio ?? null, skill_tier ?? null, userId]
        );

        if (interests) {
          await client.query('DELETE FROM user_interests WHERE user_id = $1', [userId]);
          for (const interest of interests) {
            await client.query(
              'INSERT INTO user_interests (user_id, interest) VALUES ($1, $2)', [userId, interest]
            );
          }
        }

        if (goals) {
          await client.query('DELETE FROM user_goals WHERE user_id = $1', [userId]);
          for (const goal of goals) {
            await client.query(
              'INSERT INTO user_goals (user_id, goal) VALUES ($1, $2)', [userId, goal]
            );
          }
        }

        await client.query('COMMIT');

        // Return updated profile
        const userResult = await fastify.db.query(
          `SELECT id, username, niche, bio, skill_tier, xp, created_at FROM users WHERE id = $1`, [userId]
        );
        const user = userResult.rows[0];
        const [interestsRes, goalsRes, socialsRes, rivalCount] = await Promise.all([
          fastify.db.query(`SELECT interest FROM user_interests WHERE user_id = $1`, [userId]),
          fastify.db.query(`SELECT goal FROM user_goals WHERE user_id = $1`, [userId]),
          fastify.db.query(`SELECT platform, connected, profile_url FROM social_connections WHERE user_id = $1`, [userId]),
          fastify.db.query(`SELECT COUNT(*) FROM rivals WHERE user_a = $1 OR user_b = $1`, [userId]),
        ]);

        const solvedStats = await getSolvedStats(fastify.db, userId);
        return reply.send({
          ...user,
          rank:                xpToRank(user.xp),
          interests:           interestsRes.rows.map((r: any) => r.interest),
          goals:               goalsRes.rows.map((r: any) => r.goal),
          socials:             socialsRes.rows,
          rivalCount:          Number(rivalCount.rows[0].count),
          problems_solved:     solvedStats.problems_solved,
          solved_by_difficulty: solvedStats.solved_by_difficulty,
          solved_by_type:      solvedStats.solved_by_type,
        });

      } catch (err) {
        await client.query('ROLLBACK');
        fastify.log.error(err);
        return reply.status(500).send({ error: 'Internal server error' });
      } finally {
        client.release();
      }
    }
  );
}