"use strict";
/**
 * Database initialization utility
 * Automatically initializes the database schema if it doesn't exist
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.initializeDatabase = initializeDatabase;
const fs_1 = require("fs");
const path_1 = require("path");
const pg_1 = require("pg");
async function initializeDatabase(databaseUrl) {
    const pool = new pg_1.Pool({ connectionString: databaseUrl });
    try {
        const client = await pool.connect();
        try {
            // Check if users table exists
            const tableCheck = await client.query(`SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_schema = 'public' AND table_name = 'users'
        )`);
            if (tableCheck.rows[0].exists) {
                console.error('[DB] ✅ Database already initialized - users table exists');
                return;
            }
            console.error('[DB] Database not initialized - running migration...');
            // Try to find and read the migration SQL file
            const distPath = (0, path_1.resolve)(__dirname, '../db/migrate.sql');
            const srcPath = (0, path_1.resolve)(__dirname, '../../src/db/migrate.sql');
            console.error(`[DB] Checking for migration file...`);
            console.error(`[DB]   Dist path: ${distPath} (exists: ${(0, fs_1.existsSync)(distPath)})`);
            console.error(`[DB]   Src path: ${srcPath} (exists: ${(0, fs_1.existsSync)(srcPath)})`);
            let migrateSql;
            if ((0, fs_1.existsSync)(distPath)) {
                console.error(`[DB] ✅ Found migration file at dist path`);
                migrateSql = (0, fs_1.readFileSync)(distPath, 'utf-8');
            }
            else if ((0, fs_1.existsSync)(srcPath)) {
                console.error(`[DB] ✅ Found migration file at src path`);
                migrateSql = (0, fs_1.readFileSync)(srcPath, 'utf-8');
            }
            else {
                throw new Error(`Migration file not found at ${distPath} or ${srcPath}`);
            }
            console.error('[DB] Running migration SQL...');
            await client.query(migrateSql);
            console.error('[DB] ✅ Database schema initialized successfully');
            // Verify tables exist
            const tableResult = await client.query(`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`);
            const tables = tableResult.rows.map((r) => r.table_name);
            console.error(`[DB] 📊 Created tables: ${tables.join(', ')}`);
        }
        finally {
            client.release();
        }
    }
    catch (err) {
        console.error('[DB] ❌ Database initialization failed:');
        console.error(err);
        throw err;
    }
    finally {
        await pool.end();
    }
}
