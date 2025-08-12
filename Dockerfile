# Railway-Optimized Dockerfile for Aditi Consulting AI
FROM node:20-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    make \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    musl-dev \
    giflib-dev \
    pixman-dev \
    pangomm-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    pkgconfig \
    bash \
    curl \
    git \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Frontend build stage
FROM base AS frontend-builder

# Copy frontend package files first for better caching
COPY frontend/package.json frontend/yarn.lock ./frontend/

# Install frontend dependencies
WORKDIR /app/frontend
RUN yarn install --frozen-lockfile --network-timeout 600000

# Copy frontend source and build
COPY frontend/ ./
RUN NODE_OPTIONS="--max-old-space-size=4096" yarn build

# Server dependencies stage  
FROM base AS server-builder

# Copy server package files first for better caching
COPY server/package.json server/yarn.lock ./server/

# Install server dependencies
WORKDIR /app/server
RUN yarn install --frozen-lockfile --production --network-timeout 600000

# Copy server source
COPY server/ ./

# Generate Prisma client
RUN npx prisma generate --schema=./prisma/schema.prisma

# Collector dependencies stage
FROM base AS collector-builder

# Copy collector package files first for better caching
COPY collector/package.json collector/yarn.lock ./collector/

# Install collector dependencies
WORKDIR /app/collector
RUN yarn install --frozen-lockfile --production --network-timeout 600000

# Copy collector source
COPY collector/ ./

# Final production stage
FROM node:20-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    cairo \
    jpeg \
    pango \
    musl \
    giflib \
    pixman \
    pangomm \
    libjpeg-turbo \
    freetype \
    ttf-dejavu \
    fontconfig \
    bash \
    curl \
    sqlite \
    && rm -rf /var/cache/apk/*

# Create app user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S anythingllm -u 1001 -G nodejs

# Set working directory
WORKDIR /app

# Copy built applications with proper ownership
COPY --from=server-builder --chown=anythingllm:nodejs /app/server ./server
COPY --from=collector-builder --chown=anythingllm:nodejs /app/collector ./collector
COPY --from=frontend-builder --chown=anythingllm:nodejs /app/frontend/dist ./server/public

# Copy root package.json
COPY --chown=anythingllm:nodejs package.json ./

# Create necessary directories with proper permissions
RUN mkdir -p /app/server/storage/documents \
    && mkdir -p /app/server/storage/vector-cache \
    && mkdir -p /app/server/storage/lancedb \
    && mkdir -p /app/collector/hotdir \
    && mkdir -p /app/collector/storage/tmp \
    && mkdir -p /app/server/logs \
    && chown -R anythingllm:nodejs /app \
    && chmod -R 755 /app

# Set environment variables for Railway
ENV NODE_ENV=production
ENV SERVER_PORT=${PORT:-3001}
ENV COLLECTOR_PORT=8888
ENV STORAGE_DIR=/app/server/storage
ENV DATABASE_URL="file:/app/server/storage/anythingllm.db"
ENV JWT_SECRET=${JWT_SECRET:-"aditi-consulting-jwt-secret-key-32-characters-long-string"}
ENV SIG_KEY=${SIG_KEY:-"aditi-consulting-signature-key-32-characters-minimum-length"}
ENV SIG_SALT=${SIG_SALT:-"aditi-consulting-salt-key-32-characters-minimum-length-req"}
ENV VECTOR_DB=${VECTOR_DB:-"lancedb"}
ENV LLM_PROVIDER=${LLM_PROVIDER:-"openai"}
ENV EMBEDDING_ENGINE=${EMBEDDING_ENGINE:-"native"}
ENV TTS_PROVIDER=${TTS_PROVIDER:-"native"}
ENV WHISPER_PROVIDER=${WHISPER_PROVIDER:-"local"}

# Expose the port (Railway will set PORT env var)
EXPOSE ${PORT:-3001}

# Copy and set up entrypoint script
COPY --chown=anythingllm:nodejs docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

# Switch to non-root user
USER anythingllm

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD node -e "require('http').get('http://localhost:${PORT:-3001}/api/ping', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start the application
ENTRYPOINT ["./docker-entrypoint.sh"]