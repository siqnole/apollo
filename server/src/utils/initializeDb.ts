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
        console.log('db already initialized - users table exists');
        return;
      }

      console.log('db not initialized - running migration...');

      // Read and execute migration SQL
      // In production, the file is at dist/db/migrate.sql
      // In development, we go back to src/db/migrate.sql
      let migratePath = resolve(__dirname, '../db/migrate.sql');
      
      try {
        // Try production path first
        readFileSync(migratePath);
      } catch {
        // Fall back to source path for development
        migratePath = resolve(__dirname, '../../src/db/migrate.sql');
      }
      
      const migrateSql = readFileSync(migratePath, 'utf-8');

      await client.query(migrateSql);
      console.log('db schema initialized successfully');

      // Verify tables exist
      const tableResult = await client.query(
        `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`
      );
      const tables = tableResult.rows.map((r: any) => r.table_name);
      console.log(`created: ${tables.join(', ')}`);
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('db initialization failed:', err);
    throw err;
  } finally {
    await pool.end();
  }
}
