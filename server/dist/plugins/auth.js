"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const fastify_plugin_1 = __importDefault(require("fastify-plugin"));
exports.default = (0, fastify_plugin_1.default)(async (fastify) => {
    fastify.decorate('authenticate', async (req, reply) => {
        try {
            // Try Authorization header first, then cookie
            const authHeader = req.headers.authorization;
            if (authHeader?.startsWith('Bearer ')) {
                const token = authHeader.slice(7);
                const payload = fastify.jwt.verify(token);
                req.userId = payload.sub;
                req.username = payload.username;
                return;
            }
            // Fall back to cookie
            const cookie = req.cookies?.apollo_token;
            if (cookie) {
                const payload = fastify.jwt.verify(cookie);
                req.userId = payload.sub;
                req.username = payload.username;
                return;
            }
            return reply.status(401).send({ error: 'Unauthorized' });
        }
        catch {
            return reply.status(401).send({ error: 'Unauthorized' });
        }
    });
    fastify.decorate('authenticateOptional', async (req, reply) => {
        try {
            // Try Authorization header first, then cookie
            const authHeader = req.headers.authorization;
            if (authHeader?.startsWith('Bearer ')) {
                const token = authHeader.slice(7);
                const payload = fastify.jwt.verify(token);
                req.userId = payload.sub;
                req.username = payload.username;
                return;
            }
            // Fall back to cookie
            const cookie = req.cookies?.apollo_token;
            if (cookie) {
                const payload = fastify.jwt.verify(cookie);
                req.userId = payload.sub;
                req.username = payload.username;
                return;
            }
            // If not authenticated, just continue (userId will be undefined)
        }
        catch {
            // If not authenticated, just continue (userId will be undefined)
        }
    });
});
