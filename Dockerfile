# Multi-stage build for Apollo (React + Node backend)

# Stage 1: Build client (React)
FROM node:20-alpine AS client-builder
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Stage 2: Build server (Node/TypeScript)
FROM node:20-alpine AS server-builder
WORKDIR /app

COPY server/package*.json ./server/
RUN cd server && npm ci --production && cd ..

COPY server/tsconfig.json ./server/
COPY server/src ./server/src
RUN cd server && npm run build && cd ..

# Stage 3: Production image
FROM node:20-alpine
WORKDIR /app

# Install production dependencies for server
COPY server/package*.json ./server/
RUN cd server && npm install --omit=dev && cd ..

# Copy compiled server
COPY --from=server-builder /app/server/dist ./server/dist

# Copy built React app for static serving
COPY --from=client-builder /app/build ./build

# Expose port
EXPOSE 3001

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3001
ENV HOST=0.0.0.0

# Start server
CMD ["node", "server/dist/index.js"]
