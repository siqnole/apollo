#!/usr/bin/env node
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

import 'dotenv/config';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import { Pool } from 'pg';

const DATABASE_URL = process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error('ERROR: DATABASE_URL environment variable not set');
  process.exit(1);
}

async function initDatabase() {
  const pool = new Pool({ connectionString: DATABASE_URL });

  try {
    console.log('🔌 Connecting to database...');
    const client = await pool.connect();

    try {
      // Read and execute migration SQL
      const migrateSql = readFileSync(
        resolve(__dirname, '../db/migrate.sql'),
        'utf-8'
      );

      console.log('🚀 Running migration...');
      await client.query(migrateSql);
      console.log('✅ Database schema initialized successfully');

      // Verify tables exist
      const tableResult = await client.query(
        `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'`
      );
      const tables = tableResult.rows.map((r: any) => r.table_name).sort();
      console.log(`📊 Tables created: ${tables.join(', ')}`);
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('❌ Database initialization failed:', err instanceof Error ? err.message : String(err));
    process.exit(1);
  } finally {
    await pool.end();
  }
}

initDatabase().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
