#!/usr/bin/env node
"use strict";
/**
 * Database initialization script
 * Run this after deploying to a new environment or after database reset
 *
 * Usage:
 *   npm run init-db
 *
 * Environment variables:
 *   DATABASE_URL - Connection string (required)
 */
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const fs_1 = require("fs");
const path_1 = require("path");
const pg_1 = require("pg");
const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) {
    console.error('ERROR: DATABASE_URL environment variable not set');
    process.exit(1);
}
async function initDatabase() {
    const pool = new pg_1.Pool({ connectionString: DATABASE_URL });
    try {
        console.log('🔌 Connecting to database...');
        const client = await pool.connect();
        try {
            // Read and execute migration SQL
            const migrateSql = (0, fs_1.readFileSync)((0, path_1.resolve)(__dirname, '../db/migrate.sql'), 'utf-8');
            console.log('🚀 Running migration...');
            await client.query(migrateSql);
            console.log('✅ Database schema initialized successfully');
            // Verify tables exist
            const tableResult = await client.query(`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'`);
            const tables = tableResult.rows.map((r) => r.table_name).sort();
            console.log(`📊 Tables created: ${tables.join(', ')}`);
        }
        finally {
            client.release();
        }
    }
    catch (err) {
        console.error('❌ Database initialization failed:', err instanceof Error ? err.message : String(err));
        process.exit(1);
    }
    finally {
        await pool.end();
    }
}
initDatabase().catch((err) => {
    console.error('Fatal error:', err);
    process.exit(1);
});
