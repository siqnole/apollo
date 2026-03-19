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
                console.log('✅ Database already initialized - users table exists');
                return;
            }
            console.log('🚀 Database not initialized - running migration...');
            // Read and execute migration SQL
            const migrateSql = (0, fs_1.readFileSync)((0, path_1.resolve)(__dirname, '../db/migrate.sql'), 'utf-8');
            await client.query(migrateSql);
            console.log('✅ Database schema initialized successfully');
            // Verify tables exist
            const tableResult = await client.query(`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`);
            const tables = tableResult.rows.map((r) => r.table_name);
            console.log(`📊 Tables created: ${tables.join(', ')}`);
        }
        finally {
            client.release();
        }
    }
    catch (err) {
        console.error('❌ Database initialization failed:', err);
        throw err;
    }
    finally {
        await pool.end();
    }
}
