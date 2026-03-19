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

      let schemaInitialized = tableCheck.rows[0].exists;

      if (!schemaInitialized) {
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
      } else {
        console.error('[DB] ✅ Database schema already exists');
      }

      // Check if problems exist
      const problemCount = await client.query('SELECT COUNT(*) FROM problems');
      const problemsExist = parseInt(problemCount.rows[0].count) > 0;

      // Dynamically load all SQL files from db directory (even if schema exists)
      if (!problemsExist) {
        console.error('[DB] No problems found - loading problem data...');
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
      } else {
        console.error(`[DB] ✅ Problems already loaded (${problemCount.rows[0].count} problems)`);
      }

      // Verify tables exist
      const tableResult = await client.query(
        `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`
      );
      const tables = tableResult.rows.map((r: any) => r.table_name);
      console.error(`[DB] 📊 Created tables: ${tables.join(', ')}`);

      // Check final problem count
      const finalProblems = await client.query('SELECT COUNT(*) FROM problems');
      console.error(`[DB] 📊 Total problems: ${finalProblems.rows[0].count}`);
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
