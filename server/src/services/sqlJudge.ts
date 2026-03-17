import { Pool } from 'pg';
import * as crypto from 'crypto';

// ── Types ──────────────────────────────────────────────────────────────────

export interface SqlJudgeResult {
  status:     'accepted' | 'wrong_answer' | 'runtime_error';
  output:     string;
  runtime_ms: number;
  actual?:    any[];
  expected?:  any[];
}

// ── Normalise a result set for comparison ──────────────────────────────────

function normaliseRows(rows: any[]): string {
  return JSON.stringify(
    rows.map(row =>
      Object.fromEntries(
        Object.entries(row).map(([k, v]) => [
          k.toLowerCase(),
          v === null ? null : String(v).trim().toLowerCase(),
        ])
      )
    ).sort((a, b) => JSON.stringify(a).localeCompare(JSON.stringify(b)))
  );
}

// ── Main judge ─────────────────────────────────────────────────────────────

export async function judgeSql(
  pool:        Pool,
  setupSql:    string,   // CREATE TABLE + INSERT seed data
  expectedSql: string,   // the canonical correct query
  userSql:     string,   // the user's submitted query
): Promise<SqlJudgeResult> {
  const schemaId = `sandbox_${crypto.randomUUID().replace(/-/g, '_')}`;
  const start    = Date.now();
  const client   = await pool.connect();

  try {
    // Isolated schema so nothing touches real tables
    await client.query(`CREATE SCHEMA ${schemaId}`);
    await client.query(`SET search_path TO ${schemaId}`);

    // Seed the schema
    await client.query(setupSql);

    // Run expected query
    let expectedRows: any[];
    try {
      const res = await client.query(expectedSql);
      expectedRows = res.rows;
    } catch (e: any) {
      return { status: 'runtime_error', output: `Internal error in expected query: ${e.message}`, runtime_ms: 0 };
    }

    // Run user query — catch syntax/runtime errors gracefully
    let actualRows: any[];
    try {
      // Only allow SELECT statements — block mutations
      const trimmed = userSql.trim().toUpperCase();
      if (!trimmed.startsWith('SELECT') && !trimmed.startsWith('WITH')) {
        return { status: 'runtime_error', output: 'Only SELECT queries are allowed.', runtime_ms: 0 };
      }
      const res = await client.query(userSql);
      actualRows = res.rows;
    } catch (e: any) {
      return {
        status:     'runtime_error',
        output:     e.message?.split('\n')[0] ?? 'Query error',
        runtime_ms: Date.now() - start,
      };
    }

    const runtime_ms = Date.now() - start;
    const passed     = normaliseRows(actualRows) === normaliseRows(expectedRows);

    return {
      status:     passed ? 'accepted' : 'wrong_answer',
      output:     passed
        ? `Correct! ${actualRows.length} row(s) returned.`
        : `Wrong result. Got ${actualRows.length} row(s), expected ${expectedRows.length} row(s).`,
      runtime_ms,
      actual:   actualRows,
      expected: expectedRows,
    };

  } finally {
    // Always clean up the schema and reset search_path before returning
    // the client to the pool — otherwise subsequent queries on this client
    // will look in the sandbox schema instead of public.
    try {
      await client.query(`DROP SCHEMA IF EXISTS ${schemaId} CASCADE`);
    } catch { /* ignore cleanup errors */ }
    try {
      await client.query(`SET search_path TO public`);
    } catch { /* ignore */ }
    client.release();
  }
}