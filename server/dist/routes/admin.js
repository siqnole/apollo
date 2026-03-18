"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = adminRoutes;
// ── Admin key guard ────────────────────────────────────────────────────────
async function requireAdmin(req, reply) {
    const key = req.headers['x-admin-key'];
    if (!process.env.ADMIN_KEY || key !== process.env.ADMIN_KEY) {
        return reply.status(403).send({ error: 'Forbidden' });
    }
}
async function adminRoutes(app) {
    // ── POST /api/appeals ─────────────────────────────────────────────────────
    // User submits a ban appeal. Auth optional — appeal saved regardless.
    // Includes the pasted code so admins can check it for AI.
    app.post('/appeals', async (req, reply) => {
        let userId = null;
        try {
            await req.jwtVerify();
            userId = req.user?.sub ?? null;
        }
        catch { }
        const { slug, reason, code } = req.body;
        if (!slug || !reason?.trim()) {
            return reply.status(400).send({ error: 'slug and reason are required' });
        }
        await app.db.query(`INSERT INTO appeals (user_id, slug, reason, code) VALUES ($1, $2, $3, $4)`, [userId, slug, reason.trim(), code ?? null]);
        return { ok: true };
    });
    // ── GET /api/appeals/check/:slug ──────────────────────────────────────────
    // Client polls on problem load to see if admin cleared their ban.
    // Returns { cleared: true } so client can remove the localStorage entry.
    app.get('/appeals/check/:slug', async (req) => {
        let userId = null;
        try {
            await req.jwtVerify();
            userId = req.user?.sub ?? null;
        }
        catch { }
        if (!userId)
            return { cleared: false };
        const { slug } = req.params;
        const { rows } = await app.db.query(`SELECT status FROM appeals
       WHERE user_id = $1 AND slug = $2
       ORDER BY created_at DESC
       LIMIT 1`, [userId, slug]);
        return { cleared: rows[0]?.status === 'cleared' };
    });
    // ── GET /api/admin/appeals ────────────────────────────────────────────────
    app.get('/admin/appeals', { preHandler: requireAdmin }, async (req) => {
        const { status } = req.query;
        const { rows } = await app.db.query(`SELECT
         a.id, a.user_id, u.username, a.slug,
         a.reason, a.code, a.status, a.created_at
       FROM appeals a
       LEFT JOIN users u ON a.user_id = u.id
       ${status ? 'WHERE a.status = $1' : ''}
       ORDER BY a.created_at DESC
       LIMIT 200`, status ? [status] : []);
        return { appeals: rows };
    });
    // ── PATCH /api/admin/appeals/:id ──────────────────────────────────────────
    // 'cleared' lifts the ban (client detects via /appeals/check/:slug)
    // 'upheld'  keeps the ban
    app.patch('/admin/appeals/:id', { preHandler: requireAdmin }, async (req, reply) => {
        const { id } = req.params;
        const { status } = req.body;
        if (!['cleared', 'upheld'].includes(status)) {
            return reply.status(400).send({ error: 'status must be cleared or upheld' });
        }
        const { rowCount } = await app.db.query(`UPDATE appeals SET status = $1 WHERE id = $2`, [status, id]);
        if (rowCount === 0)
            return reply.status(404).send({ error: 'Appeal not found' });
        return { ok: true };
    });
    // ── GET /api/admin/submissions ────────────────────────────────────────────
    app.get('/admin/submissions', { preHandler: requireAdmin }, async (req) => {
        const { slug, status, user, limit = '50', offset = '0', } = req.query;
        const conditions = [];
        const params = [];
        let i = 1;
        if (slug) {
            conditions.push(`p.slug ILIKE $${i++}`);
            params.push(`%${slug}%`);
        }
        if (status) {
            conditions.push(`s.status = $${i++}`);
            params.push(status);
        }
        if (user) {
            conditions.push(`u.username ILIKE $${i++}`);
            params.push(`%${user}%`);
        }
        params.push(Math.min(parseInt(limit, 10), 200));
        params.push(Math.max(parseInt(offset, 10), 0));
        const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
        const { rows } = await app.db.query(`SELECT
         s.id, s.user_id, u.username,
         p.slug AS problem_slug,
         s.problem_type, s.language,
         s.code, s.answer,
         s.status, s.output, s.runtime_ms,
         s.xp_awarded, s.test_results, s.created_at
       FROM submissions s
       LEFT JOIN users u    ON s.user_id    = u.id
       LEFT JOIN problems p ON s.problem_id = p.id
       ${where}
       ORDER BY s.created_at DESC
       LIMIT $${i++} OFFSET $${i++}`, params);
        return { submissions: rows };
    });
}
