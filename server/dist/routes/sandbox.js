"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = sandboxRoutes;
const child_process_1 = require("child_process");
const util_1 = require("util");
const crypto = __importStar(require("crypto"));
const execAsync = (0, util_1.promisify)(child_process_1.exec);
const SESSION_TTL_MS = 30 * 60 * 1000; // 30 minutes
const EXEC_TIMEOUT_MS = 8000;
const MAX_OUTPUT_BYTES = 50000;
const sessions = new Map();
const IMAGES = {
    shell: 'apollo-shell',
    shell_sql: 'apollo-shell-sql',
};
async function startContainer(problemSlug, problemType) {
    const image = IMAGES[problemType] ?? 'apollo-shell';
    const { stdout } = await execAsync(`docker run -d \
      --network none \
      --memory 256m \
      --cpus 0.5 \
      --pids-limit 128 \
      -e PROBLEM=${problemSlug} \
      ${image}`, { timeout: 30000 });
    return stdout.trim();
}
async function execInContainer(containerId, command, cwd) {
    const safe = command.replace(/'/g, `'\\''`);
    try {
        const { stdout, stderr } = await execAsync(`docker exec -w ${JSON.stringify(cwd)} -u user ${containerId} bash -c '${safe}'`, { timeout: EXEC_TIMEOUT_MS, maxBuffer: MAX_OUTPUT_BYTES });
        return { stdout, stderr, exitCode: 0 };
    }
    catch (e) {
        return {
            stdout: (e.stdout ?? '').slice(0, MAX_OUTPUT_BYTES),
            stderr: (e.stderr ?? e.message ?? 'Command failed').slice(0, 2000),
            exitCode: e.code ?? 1,
        };
    }
}
async function destroyContainer(containerId) {
    await execAsync(`docker rm -f ${containerId}`).catch(() => { });
}
async function checkSolution(containerId, problemSlug) {
    try {
        const { stdout, exitCode } = await execInContainer(containerId, `check-solution ${problemSlug}`, '/home/user');
        return { passed: exitCode === 0, message: stdout.trim() || (exitCode === 0 ? 'Correct!' : 'Not quite.') };
    }
    catch {
        return { passed: false, message: 'Could not run checker.' };
    }
}
// ── Auto-cleanup expired sessions every minute ────────────────────────────
setInterval(async () => {
    const now = Date.now();
    for (const [sid, s] of sessions.entries()) {
        if (now >= s.expiresAt) {
            await destroyContainer(s.containerId);
            sessions.delete(sid);
        }
    }
}, 60_000);
async function sandboxRoutes(fastify) {
    // ── POST /api/sandbox/start ───────────────────────────────────────────────
    fastify.post('/sandbox/start', {
        preHandler: [fastify.authenticate],
    }, async (req, reply) => {
        const { userId } = req;
        const { problem_slug } = req.body;
        if (!problem_slug)
            return reply.status(400).send({ error: 'problem_slug required' });
        const result = await fastify.db.query(`SELECT id, slug, problem_type FROM problems WHERE slug = $1 AND active = true`, [problem_slug]);
        if (result.rows.length === 0)
            return reply.status(404).send({ error: 'Problem not found' });
        const { problem_type } = result.rows[0];
        if (problem_type !== 'shell' && problem_type !== 'shell_sql') {
            return reply.status(400).send({ error: 'Not a shell problem' });
        }
        // Kill any existing session for this user+problem
        for (const [sid, s] of sessions.entries()) {
            if (s.userId === userId && s.problemSlug === problem_slug) {
                await destroyContainer(s.containerId);
                sessions.delete(sid);
            }
        }
        try {
            const containerId = await startContainer(problem_slug, problem_type);
            const sessionId = crypto.randomUUID();
            const expiresAt = Date.now() + SESSION_TTL_MS;
            sessions.set(sessionId, {
                containerId,
                problemSlug: problem_slug,
                problemType: problem_type,
                userId,
                expiresAt,
            });
            return reply.send({ session_id: sessionId, expires_at: expiresAt });
        }
        catch (e) {
            fastify.log.error(e);
            return reply.status(500).send({ error: 'Failed to start sandbox. Is Docker running?' });
        }
    });
    // ── POST /api/sandbox/reset-timer ────────────────────────────────────────
    fastify.post('/sandbox/reset-timer', {
        preHandler: [fastify.authenticate],
    }, async (req, reply) => {
        const { userId } = req;
        const { session_id } = req.body;
        const session = sessions.get(session_id);
        if (!session)
            return reply.status(404).send({ error: 'Session not found' });
        if (session.userId !== userId)
            return reply.status(403).send({ error: 'Forbidden' });
        session.expiresAt = Date.now() + SESSION_TTL_MS;
        return reply.send({ expires_at: session.expiresAt });
    });
    // ── POST /api/sandbox/exec ────────────────────────────────────────────────
    fastify.post('/sandbox/exec', {
        preHandler: [fastify.authenticate],
    }, async (req, reply) => {
        const { userId } = req;
        const { session_id, command, cwd } = req.body;
        if (!session_id || !command)
            return reply.status(400).send({ error: 'session_id and command required' });
        const session = sessions.get(session_id);
        if (!session)
            return reply.status(404).send({ error: 'Session not found or expired' });
        if (session.userId !== userId)
            return reply.status(403).send({ error: 'Forbidden' });
        const blocked = /^\s*(rm\s+-rf\s+\/[^h]|mkfs|dd\s+if=\/dev\/(sd|hd|nvme))/;
        if (blocked.test(command)) {
            return reply.send({ stdout: '', stderr: 'Command blocked.', exitCode: 1, cwd });
        }
        let newCwd = cwd || '/home/user';
        // Handle cd — resolve new path inside container
        const cdMatch = command.trim().match(/^cd\s*(.*)?$/);
        if (cdMatch) {
            const target = cdMatch[1]?.trim() || '/home/user';
            const { stdout, exitCode } = await execInContainer(session.containerId, `cd ${JSON.stringify(target)} && pwd`, newCwd);
            if (exitCode === 0)
                newCwd = stdout.trim();
            return reply.send({
                stdout: '',
                stderr: exitCode !== 0 ? `cd: ${target}: No such file or directory` : '',
                exitCode,
                cwd: newCwd,
            });
        }
        const { stdout, stderr, exitCode } = await execInContainer(session.containerId, command, newCwd);
        return reply.send({ stdout, stderr, exitCode, cwd: newCwd });
    });
    // ── POST /api/sandbox/check ───────────────────────────────────────────────
    fastify.post('/sandbox/check', {
        preHandler: [fastify.authenticate],
    }, async (req, reply) => {
        const { userId } = req;
        const { session_id, problem_slug } = req.body;
        const session = sessions.get(session_id);
        if (!session)
            return reply.status(404).send({ error: 'Session not found' });
        if (session.userId !== userId)
            return reply.status(403).send({ error: 'Forbidden' });
        const { passed, message } = await checkSolution(session.containerId, problem_slug);
        if (passed) {
            const problemResult = await fastify.db.query(`SELECT id, xp_reward FROM problems WHERE slug = $1`, [problem_slug]);
            const problem = problemResult.rows[0];
            const prev = await fastify.db.query(`SELECT id FROM submissions WHERE user_id = $1 AND problem_id = $2 AND status = 'accepted'`, [userId, problem.id]);
            let xpAwarded = 0;
            if (prev.rows.length === 0) {
                xpAwarded = problem.xp_reward;
                await fastify.db.query(`UPDATE users SET xp = xp + $1 WHERE id = $2`, [xpAwarded, userId]);
                await fastify.db.query(`INSERT INTO submissions (user_id, problem_id, problem_type, status, xp_awarded)
           VALUES ($1, $2, $3, 'accepted', $4)`, [userId, problem.id, session.problemType, xpAwarded]);
            }
            // Destroy container now that problem is solved
            await destroyContainer(session.containerId);
            sessions.delete(session_id);
            return reply.send({ passed: true, message, xp_awarded: xpAwarded });
        }
        return reply.send({ passed: false, message, xp_awarded: 0 });
    });
    // ── DELETE /api/sandbox/:session_id ──────────────────────────────────────
    fastify.delete('/sandbox/:session_id', {
        preHandler: [fastify.authenticate],
    }, async (req, reply) => {
        const { userId } = req;
        const { session_id } = req.params;
        const session = sessions.get(session_id);
        if (session && session.userId === userId) {
            await destroyContainer(session.containerId);
            sessions.delete(session_id);
        }
        return reply.send({ ok: true });
    });
}
