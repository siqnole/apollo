"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config"); // must be first line
const fastify_plugin_1 = __importDefault(require("fastify-plugin"));
const pg_1 = require("pg");
exports.default = (0, fastify_plugin_1.default)(async (fastify) => {
    const pool = new pg_1.Pool({
        connectionString: process.env.DATABASE_URL,
        connectionTimeoutMillis: 10000,
        idleTimeoutMillis: 30000,
        max: 5,
        // Don't create connections until needed (lazy)
    });
    // Log pool creation but don't verify connection on startup
    // Free tier databases need time to spin up, so we let it connect lazily
    fastify.log.info('PostgreSQL pool created (lazy connect)');
    fastify.decorate('db', pool);
    // Handle pool errors
    pool.on('error', (err) => {
        fastify.log.error(`Unexpected db pool error: ${err instanceof Error ? err.message : String(err)}`);
    });
    fastify.addHook('onClose', async () => {
        try {
            await pool.end();
            fastify.log.info('PostgreSQL pool closed');
        }
        catch (err) {
            fastify.log.warn(`Error closing pool: ${err instanceof Error ? err.message : String(err)}`);
        }
    });
});
