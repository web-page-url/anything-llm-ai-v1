# Ultra-Fast Railway-Optimized Dockerfile for Aditi Consulting AI
FROM node:20-alpine

# Install system dependencies with optimizations for faster builds
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
    sqlite \
    ttf-dejavu \
    fontconfig \
    && rm -rf /var/cache/apk/*

# Set build optimizations to avoid timeouts
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1
ENV npm_config_build_from_source=false
ENV npm_config_cache_max=0

# Install Chromium for Puppeteer
RUN apk add --no-cache chromium

# Create app user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S anythingllm -u 1001 -G nodejs

# Set working directory
WORKDIR /app

# Copy package files only (yarn.lock files are in .gitignore)
COPY package.json ./
COPY frontend/package.json ./frontend/
COPY server/package.json ./server/
COPY collector/package.json ./collector/

# Install dependencies with optimizations to prevent build timeouts
RUN cd frontend && yarn install --network-timeout 600000 --prefer-offline --production=false && cd ..
RUN cd server && yarn install --production --network-timeout 600000 --prefer-offline && cd ..
RUN cd collector && yarn install --production --network-timeout 600000 --prefer-offline && cd ..

# Copy source code
COPY frontend/ ./frontend/
COPY server/ ./server/
COPY collector/ ./collector/

# Build frontend
WORKDIR /app/frontend
RUN NODE_OPTIONS="--max-old-space-size=4096" yarn build

# Generate Prisma client
WORKDIR /app/server
RUN npx prisma generate --schema=./prisma/schema.prisma

# Move built frontend to server public directory
WORKDIR /app
RUN mkdir -p server/public && cp -r frontend/dist/* server/public/ || echo "Frontend build files copied"

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
COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh && chown anythingllm:nodejs docker-entrypoint.sh

# Switch to non-root user
USER anythingllm

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD node -e "require('http').get('http://localhost:${PORT:-3001}/api/ping', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start the application
ENTRYPOINT ["./docker-entrypoint.sh"]