/**
 * Database initialization utility
 * Automatically initializes the database schema if it doesn't exist
 */

import { readFileSync } from 'fs';
import { resolve } from 'path';
import { Pool } from 'pg';

export async function initializeDatabase(databaseUrl: string) {
  const pool = new Pool({ connectionString: databaseUrl });

  try {
    const client = await pool.connect();

    try {
      // Check if users table exists
      const tableCheck = await client.query(
        `SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_schema = 'public' AND table_name = 'users'
        )`
      );

      if (tableCheck.rows[0].exists) {
        console.log('[DB] ✅ Database already initialized - users table exists');
        return;
      }

      console.log('[DB] Starting migration...');

      // Read and execute migration SQL
      // In production, the file is at dist/db/migrate.sql
      // In development, we go back to src/db/migrate.sql
      let migratePath = resolve(__dirname, '../db/migrate.sql');
      
      try {
        readFileSync(migratePath);
        console.log(`[DB] Using migration file at: ${migratePath}`);
      } catch {
        // Fall back to source path for development
        migratePath = resolve(__dirname, '../../src/db/migrate.sql');
        console.log(`[DB] Dist path not found, trying source path: ${migratePath}`);
        readFileSync(migratePath);
      }
      
      const migrateSql = readFileSync(migratePath, 'utf-8');
      
      console.log('[DB] Running migration SQL...');
      await client.query(migrateSql);
      console.log('[DB] ✅ Database schema initialized successfully');

      // Verify tables exist
      const tableResult = await client.query(
        `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`
      );
      const tables = tableResult.rows.map((r: any) => r.table_name);
      console.log(`[DB] 📊 Created tables: ${tables.join(', ')}`);
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('[DB] ❌ Database initialization failed:');
    console.error(err);
    throw err;
  } finally {
    await pool.end();
  }
}
