#!/bin/bash
set -e

echo "🚀 Starting Aditi Consulting AI for Railway..."
echo "🐛 DEBUG: Node version: $(node --version)"
echo "🐛 DEBUG: NPM version: $(npm --version)"
echo "🐛 DEBUG: Current directory: $(pwd)"
echo "🐛 DEBUG: PORT environment: $PORT"

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

echo "🐛 DEBUG: Environment variables set"

# Ensure storage directories exist
echo "📁 Setting up storage directories..."
mkdir -p "$STORAGE_DIR/documents" "$STORAGE_DIR/vector-cache" "$STORAGE_DIR/lancedb"
mkdir -p "/app/collector/storage/tmp" "/app/collector/hotdir" "/app/server/logs"
echo "✅ Storage directories created"

# Navigate to server directory
cd /app/server
echo "🐛 DEBUG: Changed to server directory: $(pwd)"
echo "🐛 DEBUG: Server files: $(ls -la | head -10)"

# Check if server files exist
if [ ! -f "index.js" ]; then
    echo "❌ ERROR: server/index.js not found!"
    echo "🐛 DEBUG: Available files:"
    ls -la
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "❌ ERROR: server/node_modules not found!"
    echo "🐛 DEBUG: Available directories:"
    ls -la
    exit 1
fi

# Simple database setup with better error handling
echo "🗄️ Setting up database..."
if command -v npx >/dev/null 2>&1; then
    echo "🔧 NPX available, attempting Prisma setup..."
    
    # Check if Prisma is available
    if npx prisma --version >/dev/null 2>&1; then
        echo "🔧 Prisma CLI available, generating client..."
        npx prisma generate --schema=./prisma/schema.prisma || echo "⚠️ Prisma generate failed"
        npx prisma migrate deploy --schema=./prisma/schema.prisma || echo "⚠️ Migrations failed"
    else
        echo "⚠️ Prisma CLI not available in node_modules"
    fi
else
    echo "⚠️ NPX not available"
fi
echo "✅ Database setup complete"

# Skip collector for now to simplify debugging
echo "📄 Skipping collector startup for debugging"

# Start the main server with detailed logging
echo "🔧 Starting Server on port $PORT..."
echo "🌐 Server will be available at: http://0.0.0.0:$PORT"
echo "🏥 Health check endpoint: http://0.0.0.0:$PORT/api/ping"
echo "🐛 DEBUG: About to start node index.js"

# Start server with error handling
node index.js || {
    echo "❌ ERROR: Server failed to start!"
    echo "🐛 DEBUG: Exit code: $?"
    echo "🐛 DEBUG: Checking if port is in use..."
    netstat -tulpn 2>/dev/null || echo "netstat not available"
    exit 1
}