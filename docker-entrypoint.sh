#!/bin/bash

# ULTRA-SIMPLE STARTUP - NO COMPLEXITY
echo "STARTING APPLICATION..."

# Set basic environment
export PORT=${PORT:-3001}
export NODE_ENV=production
export DATABASE_URL="file:/app/server/storage/anythingllm.db"
export STORAGE_DIR="/app/server/storage"

# Create basic directories
mkdir -p /app/server/storage/documents
mkdir -p /app/server/storage/vector-cache
mkdir -p /app/server/storage/lancedb

# Go to server directory
cd /app/server

# Start server directly - NO PRISMA, NO COMPLEXITY
echo "STARTING SERVER ON PORT $PORT..."
node index.js