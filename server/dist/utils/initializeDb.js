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
                console.log('[DB] ✅ Database already initialized - users table exists');
                return;
            }
            console.log('[DB] Starting migration...');
            // Read and execute migration SQL
            // In production, the file is at dist/db/migrate.sql
            // In development, we go back to src/db/migrate.sql
            let migratePath = (0, path_1.resolve)(__dirname, '../db/migrate.sql');
            try {
                (0, fs_1.readFileSync)(migratePath);
                console.log(`[DB] Using migration file at: ${migratePath}`);
            }
            catch {
                // Fall back to source path for development
                migratePath = (0, path_1.resolve)(__dirname, '../../src/db/migrate.sql');
                console.log(`[DB] Dist path not found, trying source path: ${migratePath}`);
                (0, fs_1.readFileSync)(migratePath);
            }
            const migrateSql = (0, fs_1.readFileSync)(migratePath, 'utf-8');
            console.log('[DB] Running migration SQL...');
            await client.query(migrateSql);
            console.log('[DB] ✅ Database schema initialized successfully');
            // Verify tables exist
            const tableResult = await client.query(`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`);
            const tables = tableResult.rows.map((r) => r.table_name);
            console.log(`[DB] 📊 Created tables: ${tables.join(', ')}`);
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
