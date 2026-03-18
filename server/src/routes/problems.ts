import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { judgeCode, judgeMultipleChoice, judgeFillBlank, judgeOrdering, extractFunctionName, runCodeRaw } from '../services/judge';
import { judgeHtml } from '../services/htmlJudge';
import { judgeSql } from '../services/sqlJudge';

export default async function problemRoutes(fastify: FastifyInstance) {

  // ── GET /api/problems ────────────────────────────────────────────────────
  fastify.get('/problems', {
    preHandler: [fastify.authenticateOptional],
  }, async (req: FastifyRequest, reply: FastifyReply) => {
    const typedReq = req as FastifyRequest<{
      Querystring: { category?: string; difficulty?: string; type?: string; search?: string }
    }>;
    const { category, difficulty, type, search } = typedReq.query;
    const { userId } = typedReq;

    let query = `
      SELECT p.id, p.slug, p.title, p.problem_type, p.difficulty, p.category, p.supported_languages,
             p.xp_reward, p.tags, p.created_at,
             COUNT(DISTINCT s.id) FILTER (WHERE s.status = 'accepted') AS solve_count,
             EXISTS(SELECT 1 FROM submissions s WHERE s.problem_id = p.id AND s.user_id = $1 AND s.status = 'accepted') AS solved
      FROM problems p
      LEFT JOIN submissions s ON s.problem_id = p.id
      WHERE p.active = true
    `;
    const params: any[] = [userId ?? null];
    let i = 2;

    if (category)   { query += ` AND p.category = $${i++}`;     params.push(category); }
    if (difficulty) { query += ` AND p.difficulty = $${i++}`;   params.push(difficulty); }
    if (type)       { query += ` AND p.problem_type = $${i++}`; params.push(type); }
    if (search)     { query += ` AND (p.title ILIKE $${i} OR p.description ILIKE $${i++})`; params.push(`%${search}%`); }

    query += ` GROUP BY p.id ORDER BY p.difficulty, p.created_at`;

    const result = await fastify.db.query(query, params);
    return reply.send({ problems: result.rows });
  });

  // ── GET /api/problems/:slug ──────────────────────────────────────────────
  fastify.get('/problems/:slug', async (req: FastifyRequest<{ Params: { slug: string } }>, reply: FastifyReply) => {
    const { slug } = req.params;

    const problemResult = await fastify.db.query(
      `SELECT * FROM problems WHERE slug = $1 AND active = true`, [slug]
    );
    if (problemResult.rows.length === 0) return reply.status(404).send({ error: 'Problem not found' });
    const problem = problemResult.rows[0];

    const [testCases, options] = await Promise.all([
      fastify.db.query(
        `SELECT id, input, expected_output, is_hidden, explanation, display_order
         FROM test_cases WHERE problem_id = $1 ORDER BY display_order`,
        [problem.id]
      ),
      fastify.db.query(
        `SELECT id, label, body, display_order, is_correct
         FROM problem_options WHERE problem_id = $1 ORDER BY display_order`,
        [problem.id]
      ),
    ]);

    const safeOptions = options.rows.map(o => ({ ...o, is_correct: undefined }));

    return reply.send({
      ...problem,
      test_cases: testCases.rows.map(tc => ({
        ...tc,
        expected_output: tc.is_hidden ? null : tc.expected_output,
      })),
      options: safeOptions,
    });
  });

  // ── POST /api/run ───────────────────────────────────────────────────────
  // Runs code and returns raw output for debugging (without judging)
  fastify.post('/run', {
    preHandler: [fastify.authenticate],
  }, async (req: FastifyRequest, reply: FastifyReply) => {
    const { language, code, input, fn_name, debug_mode } = req.body as {
      language:   string;
      code:       string;
      input?:     string;
      fn_name?:   string;
      debug_mode?: boolean;
    };

    if (!code || !language) return reply.status(400).send({ error: 'code and language required' });

    try {
      const result = await runCodeRaw(code, language, input ?? '', fn_name ?? null, debug_mode ?? false);
      return reply.send({
        output:     result.output,
        runtime_ms: result.runtime_ms,
        error:      result.error ?? null,
        stderr:     result.stderr ?? null,
      });
    } catch (err) {
      fastify.log.error(err);
      return reply.status(500).send({ error: 'Internal execution error' });
    }
  });

  // ── POST /api/submissions ────────────────────────────────────────────────
  fastify.post('/submissions', {
    preHandler: [fastify.authenticate],
  }, async (req: FastifyRequest, reply: FastifyReply) => {
    const { userId } = req;
    const { problem_slug, language, code, answer, fn_name } = req.body as {
      problem_slug: string;
      language?:    string;
      code?:        string;
      answer?:      string;
      fn_name?:     string;
    };

    const problemResult = await fastify.db.query(
      `SELECT * FROM problems WHERE slug = $1`, [problem_slug]
    );
    if (problemResult.rows.length === 0) return reply.status(404).send({ error: 'Problem not found' });
    const problem = problemResult.rows[0];

    const [testCases, options] = await Promise.all([
      fastify.db.query(`SELECT * FROM test_cases WHERE problem_id = $1 ORDER BY display_order`, [problem.id]),
      fastify.db.query(`SELECT * FROM problem_options WHERE problem_id = $1 ORDER BY display_order`, [problem.id]),
    ]);

    // ── Create pending submission ──────────────────────────────────────────
    const subResult = await fastify.db.query(
      `INSERT INTO submissions (user_id, problem_id, problem_type, language, code, answer, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'running')
       RETURNING id`,
      [userId, problem.id, problem.problem_type, language ?? null, code ?? null, answer ?? null]
    );
    const submissionId = subResult.rows[0].id;

    // ── Judge ──────────────────────────────────────────────────────────────
    let judgeResult;

    try {
      if (problem.problem_type === 'code' || problem.problem_type === 'debug') {
        if (!code || !language) return reply.status(400).send({ error: 'code and language required' });
        const detectedFn = fn_name ?? (code ? extractFunctionName(code, language) : null);
        judgeResult = await judgeCode(code, language, testCases.rows, detectedFn);

      } else if (problem.problem_type === 'sql') {
        if (!code) return reply.status(400).send({ error: 'SQL query required' });
        // setup_sql and expected_sql are stored in test_cases for sql problems:
        // test_cases[0].input       = the setup SQL (CREATE TABLE + INSERTs)
        // test_cases[0].expected_output = the canonical correct query
        const tc = testCases.rows[0];
        if (!tc) return reply.status(500).send({ error: 'No test case configured for this problem' });
        const sqlResult = await judgeSql(
          fastify.db,
          tc.input,            // setup SQL
          tc.expected_output,  // expected query
          code                 // user's query
        );
        judgeResult = {
          status:     sqlResult.status,
          output:     sqlResult.output,
          runtime_ms: sqlResult.runtime_ms,
          results:    [{
            input:   'Query result',
            expected: JSON.stringify(sqlResult.expected ?? []),
            actual:   JSON.stringify(sqlResult.actual ?? []),
            passed:   sqlResult.status === 'accepted',
            error:    sqlResult.status !== 'accepted' ? sqlResult.output : undefined,
          }],
        };

      } else if (problem.problem_type === 'multiple_choice') {
        if (!answer) return reply.status(400).send({ error: 'answer required' });
        const correct = options.rows.find((o: any) => o.is_correct);
        judgeResult = judgeMultipleChoice(answer, correct?.label ?? '');

      } else if (problem.problem_type === 'fill_blank') {
        if (!answer) return reply.status(400).send({ error: 'answer required' });
        const expected = testCases.rows[0]?.expected_output ?? '';
        judgeResult = judgeFillBlank(answer.trim(), expected.trim());

      } else if (problem.problem_type === 'ordering') {
        if (!answer) return reply.status(400).send({ error: 'answer required' });
        const submitted = JSON.parse(answer);
        const correct   = options.rows
          .filter((o: any) => o.is_correct)
          .sort((a: any, b: any) => a.display_order - b.display_order)
          .map((o: any) => o.body);
        judgeResult = judgeOrdering(submitted, correct);

      } else if (problem.problem_type === 'html_css') {
        if (!code) return reply.status(400).send({ error: 'HTML code required' });
        const htmlResult = judgeHtml(problem.slug, code);
        judgeResult = {
          status:     htmlResult.status,
          output:     htmlResult.output,
          runtime_ms: 0,
          results:    htmlResult.checks.map(c => ({
            input:    c.label,
            expected: 'pass',
            actual:   c.passed ? 'pass' : 'fail',
            passed:   c.passed,
            error:    c.passed ? undefined : c.message,
          })),
        };

      } else if (problem.problem_type === 'shell' || problem.problem_type === 'shell_sql') {
        // Shell problems are judged via POST /api/sandbox/check — not through here
        return reply.status(400).send({ error: 'Shell problems are judged via the sandbox endpoint' });

      } else {
        // short_answer
        if (!answer || answer.trim().length < 20) {
          return reply.status(400).send({ error: 'Please write at least a sentence before submitting.' });
        }
        judgeResult = {
          status:     'accepted' as const,
          output:     'Answer submitted. Keep reflecting — short answer questions build deep understanding.',
          runtime_ms: 0,
          results:    [],
        };
      }
    } catch (err) {
      fastify.log.error(err);
      judgeResult = { status: 'runtime_error' as const, output: 'Internal judge error', runtime_ms: 0, results: [] };
    }

    // ── Award XP on first-time acceptance ─────────────────────────────────
    let xpAwarded = 0;
    if (judgeResult.status === 'accepted') {
      const prev = await fastify.db.query(
        `SELECT id FROM submissions WHERE user_id = $1 AND problem_id = $2 AND status = 'accepted' AND id != $3`,
        [userId, problem.id, submissionId]
      );
      if (prev.rows.length === 0) {
        xpAwarded = problem.xp_reward;
        await fastify.db.query(`UPDATE users SET xp = xp + $1 WHERE id = $2`, [xpAwarded, userId]);
      }
    }

    // ── Update submission ──────────────────────────────────────────────────
    await fastify.db.query(
      `UPDATE submissions SET status = $1, output = $2, expected = $3, runtime_ms = $4, test_results = $5, xp_awarded = $6 WHERE id = $7`,
      [judgeResult.status, judgeResult.output, (judgeResult as any).expected ?? null, judgeResult.runtime_ms, JSON.stringify((judgeResult as any).results ?? []), xpAwarded, submissionId]
    );

    return reply.send({
      id:           submissionId,
      status:       judgeResult.status,
      output:       judgeResult.output,
      runtime_ms:   judgeResult.runtime_ms,
      test_results: (judgeResult as any).results ?? [],
      xp_awarded:   xpAwarded,
    });
  });

  // ── GET /api/submissions/:id ─────────────────────────────────────────────
  fastify.get('/submissions/:id', {
    preHandler: [fastify.authenticate],
  }, async (req: FastifyRequest, reply: FastifyReply) => {
    const { userId } = req;
    const { id }     = (req as FastifyRequest<{ Params: { id: string } }>).params;
    const result = await fastify.db.query(
      `SELECT id, status, output, runtime_ms, test_results, xp_awarded, created_at
       FROM submissions WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    if (result.rows.length === 0) return reply.status(404).send({ error: 'Submission not found' });
    return reply.send(result.rows[0]);
  });

  // ── GET /api/submissions ─────────────────────────────────────────────────
  fastify.get('/submissions', {
    preHandler: [fastify.authenticate],
  }, async (req: FastifyRequest, reply: FastifyReply) => {
    const { userId }       = req;
    const { problem_slug } = (req as FastifyRequest<{ Querystring: { problem_slug?: string } }>).query;

    let query = `
      SELECT s.id, s.status, s.language, s.runtime_ms, s.xp_awarded, s.created_at, p.slug, p.title
      FROM submissions s
      JOIN problems p ON p.id = s.problem_id
      WHERE s.user_id = $1
    `;
    const params: any[] = [userId];
    if (problem_slug) { query += ` AND p.slug = $2`; params.push(problem_slug); }
    query += ` ORDER BY s.created_at DESC LIMIT 50`;

    const result = await fastify.db.query(query, params);
    return reply.send({ submissions: result.rows });
  });
}