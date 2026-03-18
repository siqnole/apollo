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
exports.judgeSql = judgeSql;
const crypto = __importStar(require("crypto"));
// ── Normalise a result set for comparison ──────────────────────────────────
function normaliseRows(rows) {
    return JSON.stringify(rows.map(row => Object.fromEntries(Object.entries(row).map(([k, v]) => [
        k.toLowerCase(),
        v === null ? null : String(v).trim().toLowerCase(),
    ]))).sort((a, b) => JSON.stringify(a).localeCompare(JSON.stringify(b))));
}
// ── Main judge ─────────────────────────────────────────────────────────────
async function judgeSql(pool, setupSql, // CREATE TABLE + INSERT seed data
expectedSql, // the canonical correct query
userSql) {
    const schemaId = `sandbox_${crypto.randomUUID().replace(/-/g, '_')}`;
    const start = Date.now();
    const client = await pool.connect();
    try {
        // Isolated schema so nothing touches real tables
        await client.query(`CREATE SCHEMA ${schemaId}`);
        await client.query(`SET search_path TO ${schemaId}`);
        // Seed the schema
        await client.query(setupSql);
        // Run expected query
        let expectedRows;
        try {
            const res = await client.query(expectedSql);
            expectedRows = res.rows;
        }
        catch (e) {
            return { status: 'runtime_error', output: `Internal error in expected query: ${e.message}`, runtime_ms: 0 };
        }
        // Run user query — catch syntax/runtime errors gracefully
        let actualRows;
        try {
            // Only allow SELECT statements — block mutations
            const trimmed = userSql.trim().toUpperCase();
            if (!trimmed.startsWith('SELECT') && !trimmed.startsWith('WITH')) {
                return { status: 'runtime_error', output: 'Only SELECT queries are allowed.', runtime_ms: 0 };
            }
            const res = await client.query(userSql);
            actualRows = res.rows;
        }
        catch (e) {
            return {
                status: 'runtime_error',
                output: e.message?.split('\n')[0] ?? 'Query error',
                runtime_ms: Date.now() - start,
            };
        }
        const runtime_ms = Date.now() - start;
        const passed = normaliseRows(actualRows) === normaliseRows(expectedRows);
        return {
            status: passed ? 'accepted' : 'wrong_answer',
            output: passed
                ? `Correct! ${actualRows.length} row(s) returned.`
                : `Wrong result. Got ${actualRows.length} row(s), expected ${expectedRows.length} row(s).`,
            runtime_ms,
            actual: actualRows,
            expected: expectedRows,
        };
    }
    finally {
        // Always clean up the schema and reset search_path before returning
        // the client to the pool — otherwise subsequent queries on this client
        // will look in the sandbox schema instead of public.
        try {
            await client.query(`DROP SCHEMA IF EXISTS ${schemaId} CASCADE`);
        }
        catch { /* ignore cleanup errors */ }
        try {
            await client.query(`SET search_path TO public`);
        }
        catch { /* ignore */ }
        client.release();
    }
}
