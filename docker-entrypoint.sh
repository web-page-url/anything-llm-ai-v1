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

# Ensure storage directories exist with proper permissions
echo "📁 Setting up storage directories..."
mkdir -p "$STORAGE_DIR/documents"
mkdir -p "$STORAGE_DIR/vector-cache"
mkdir -p "$STORAGE_DIR/lancedb"
mkdir -p "/app/collector/storage/tmp"
mkdir -p "/app/collector/hotdir"
mkdir -p "/app/server/logs"

echo "✅ Storage directories created"

# Navigate to server directory for database operations
cd /app/server

# Database setup with error handling
echo "🗄️ Setting up database..."

# Generate Prisma client (ensure it's available)
echo "🔧 Generating Prisma client..."
npx prisma generate --schema=./prisma/schema.prisma || {
    echo "⚠️ Prisma generate failed, but continuing..."
}

# Run database migrations
echo "📊 Running database migrations..."
npx prisma migrate deploy --schema=./prisma/schema.prisma || {
    echo "⚠️ Migration failed, attempting to create database..."
    npx prisma db push --schema=./prisma/schema.prisma || echo "⚠️ Database push failed, continuing..."
}

# Seed database if needed
echo "🌱 Seeding database..."
npx prisma db seed --schema=./prisma/schema.prisma || {
    echo "⚠️ Seeding failed or not needed, continuing..."
}

echo "✅ Database setup complete"

# Function to start collector in background (only if COLLECTOR_PORT is different from main port)
start_collector() {
    if [ "$COLLECTOR_PORT" != "$PORT" ]; then
        echo "📄 Starting Document Collector on port $COLLECTOR_PORT..."
        cd /app/collector
        PORT=$COLLECTOR_PORT node index.js &
        COLLECTOR_PID=$!
        echo "📄 Collector started with PID: $COLLECTOR_PID"
        cd /app/server
    else
        echo "📄 Collector port same as server port, skipping separate collector..."
    fi
}

# Function to start server
start_server() {
    echo "🔧 Starting Server on port $PORT..."
    cd /app/server
    PORT=$PORT node index.js &
    SERVER_PID=$!
    echo "🔧 Server started with PID: $SERVER_PID"
}

# Function to handle shutdown gracefully
shutdown() {
    echo "🛑 Shutting down services gracefully..."
    if [ ! -z "$COLLECTOR_PID" ]; then
        echo "Stopping collector (PID: $COLLECTOR_PID)..."
        kill -TERM $COLLECTOR_PID 2>/dev/null || true
        wait $COLLECTOR_PID 2>/dev/null || true
    fi
    if [ ! -z "$SERVER_PID" ]; then
        echo "Stopping server (PID: $SERVER_PID)..."
        kill -TERM $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
    echo "✅ Shutdown complete"
    exit 0
}

# Set up signal handlers for graceful shutdown
trap shutdown SIGTERM SIGINT SIGQUIT

# Start services
start_collector
sleep 3  # Give collector time to start

start_server

echo "🎉 Aditi Consulting AI is running!"
echo "🌐 Server: http://localhost:$PORT"
if [ "$COLLECTOR_PORT" != "$PORT" ]; then
    echo "📄 Collector: http://localhost:$COLLECTOR_PORT"
fi
echo "💾 Storage: $STORAGE_DIR"
echo "🗄️ Database: $DATABASE_URL"

# Wait for the main server process
wait $SERVER_PID

# If server exits, cleanup and exit
echo "🔄 Server process ended, cleaning up..."
shutdown