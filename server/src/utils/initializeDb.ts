/**
 * Database initialization utility
 * Automatically initializes the database schema if it doesn't exist
 */

import { readFileSync, existsSync, readdirSync } from 'fs';
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
        console.error('[DB] ✅ Database already initialized - users table exists');
        return;
      }

      console.error('[DB] Database not initialized - running migration...');

      // Try to find and read the migration SQL file
      const distPath = resolve(__dirname, '../db/migrate.sql');
      const srcPath = resolve(__dirname, '../../src/db/migrate.sql');
      
      console.error(`[DB] Checking for migration file...`);
      console.error(`[DB]   Dist path: ${distPath} (exists: ${existsSync(distPath)})`);
      console.error(`[DB]   Src path: ${srcPath} (exists: ${existsSync(srcPath)})`);
      
      let migrateSql: string;
      if (existsSync(distPath)) {
        console.error(`[DB] ✅ Found migration file at dist path`);
        migrateSql = readFileSync(distPath, 'utf-8');
      } else if (existsSync(srcPath)) {
        console.error(`[DB] ✅ Found migration file at src path`);
        migrateSql = readFileSync(srcPath, 'utf-8');
      } else {
        throw new Error(`Migration file not found at ${distPath} or ${srcPath}`);
      }
      
      console.error('[DB] Running migration SQL...');
      await client.query(migrateSql);
      console.error('[DB] ✅ Database schema initialized successfully');

      // Dynamically load all SQL files from db directory
      const dbDir = existsSync(resolve(__dirname, '../db')) ? resolve(__dirname, '../db') : resolve(__dirname, '../../src/db');
      const allFiles = readdirSync(dbDir)
        .filter(file => file.endsWith('.sql') && file !== 'migrate.sql')
        .sort();

      console.error(`[DB] Loading ${allFiles.length} data files...`);
      for (const file of allFiles) {
        const filePath = resolve(dbDir, file);
        try {
          const sql = readFileSync(filePath, 'utf-8');
          await client.query(sql);
          console.error(`[DB]   ✅ Loaded ${file}`);
        } catch (err: any) {
          console.error(`[DB]   ⚠️  Error loading ${file}: ${err.message}`);
          // Continue loading other files even if one fails
        }
      }
      console.error('[DB] ✅ All data files loaded');

      // Verify tables exist
      const tableResult = await client.query(
        `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`
      );
      const tables = tableResult.rows.map((r: any) => r.table_name);
      console.error(`[DB] 📊 Created tables: ${tables.join(', ')}`);

      // Check problem count
      const problemCount = await client.query('SELECT COUNT(*) FROM problems');
      console.error(`[DB] 📊 Total problems: ${problemCount.rows[0].count}`);
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
