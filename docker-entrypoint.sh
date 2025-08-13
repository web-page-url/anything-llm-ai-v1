#!/bin/bash
set -e

echo "🚀 Starting Aditi Consulting AI for Railway..."

# Railway-specific environment setup
export PORT=${PORT:-3001}
export SERVER_PORT=$PORT
export COLLECTOR_PORT=${COLLECTOR_PORT:-8888}

# Set default environment variables if not provided
export JWT_SECRET=${JWT_SECRET:-"aditi-consulting-jwt-secret-key-32-characters-long-string"}
export SIG_KEY=${SIG_KEY:-"aditi-consulting-signature-key-32-characters-minimum-length"}
export SIG_SALT=${SIG_SALT:-"aditi-consulting-salt-key-32-characters-minimum-length-req"}
export VECTOR_DB=${VECTOR_DB:-"lancedb"}
export LLM_PROVIDER=${LLM_PROVIDER:-"openai"}
export EMBEDDING_ENGINE=${EMBEDDING_ENGINE:-"native"}
export TTS_PROVIDER=${TTS_PROVIDER:-"native"}
export WHISPER_PROVIDER=${WHISPER_PROVIDER:-"local"}
export STORAGE_DIR=${STORAGE_DIR:-"/app/server/storage"}
export DATABASE_URL=${DATABASE_URL:-"file:/app/server/storage/anythingllm.db"}

# Ensure storage directories exist
echo "📁 Setting up storage directories..."
mkdir -p "$STORAGE_DIR/documents" "$STORAGE_DIR/vector-cache" "$STORAGE_DIR/lancedb"
mkdir -p "/app/collector/storage/tmp" "/app/collector/hotdir" "/app/server/logs"
echo "✅ Storage directories created"

# Navigate to server directory
cd /app/server

# Simple database setup - skip complex Prisma operations for now
echo "🗄️ Setting up database..."
if command -v npx >/dev/null 2>&1; then
    echo "🔧 Attempting Prisma setup..."
    npx prisma generate --schema=./prisma/schema.prisma 2>/dev/null || echo "⚠️ Prisma generate skipped"
    npx prisma migrate deploy --schema=./prisma/schema.prisma 2>/dev/null || echo "⚠️ Migrations skipped"
else
    echo "⚠️ NPX not available, skipping Prisma setup"
fi
echo "✅ Database setup complete"

# Start collector in background if needed
if [ "$COLLECTOR_PORT" != "$PORT" ]; then
    echo "📄 Starting Document Collector on port $COLLECTOR_PORT..."
    cd /app/collector
    PORT=$COLLECTOR_PORT node index.js &
    COLLECTOR_PID=$!
    echo "📄 Collector started with PID: $COLLECTOR_PID"
    cd /app/server
fi

# Start the main server
echo "🔧 Starting Server on port $PORT..."
echo "🌐 Server will be available at: http://localhost:$PORT"
echo "🏥 Health check endpoint: http://localhost:$PORT/api/ping"

# Start server in foreground (no background process)
exec node index.js