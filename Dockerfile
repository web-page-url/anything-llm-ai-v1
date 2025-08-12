# Size-Optimized Multi-Stage Dockerfile for Railway (Under 4GB)
FROM node:20-alpine AS base

# Install build dependencies
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
    git

# Set build optimizations
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1
ENV npm_config_build_from_source=false
ENV npm_config_cache_max=0

WORKDIR /app

# Frontend build stage
FROM base AS frontend-builder
COPY frontend/package.json ./frontend/
RUN cd frontend && yarn install --network-timeout 600000 --production=false
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN yarn add regenerator-runtime core-js --dev
RUN sed -i 's/FolderNotch/Folder/g' src/components/Modals/ManageWorkspace/Documents/Directory/FolderRow/index.jsx
RUN NODE_ENV=production NODE_OPTIONS="--max-old-space-size=4096" yarn build

# Server build stage
FROM base AS server-builder
COPY server/package.json ./server/
RUN cd server && yarn install --production --network-timeout 600000
COPY server/ ./server/
WORKDIR /app/server
RUN npx prisma generate --schema=./prisma/schema.prisma
# Clean up dev dependencies and cache
RUN yarn cache clean && rm -rf node_modules/.cache

# Collector build stage
FROM base AS collector-builder
COPY collector/package.json ./collector/
RUN cd collector && yarn install --production --network-timeout 600000
COPY collector/ ./collector/
WORKDIR /app/collector
RUN yarn cache clean && rm -rf node_modules/.cache

# Final production stage - minimal runtime image
FROM node:20-alpine AS production

# Install only runtime dependencies
RUN apk add --no-cache \
    python3 \
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
    chromium \
    && rm -rf /var/cache/apk/*

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S anythingllm -u 1001 -G nodejs

WORKDIR /app

# Copy only production files (no dev dependencies)
COPY --from=server-builder --chown=anythingllm:nodejs /app/server ./server
COPY --from=collector-builder --chown=anythingllm:nodejs /app/collector ./collector
COPY --from=frontend-builder --chown=anythingllm:nodejs /app/frontend/dist ./server/public

# Copy package.json for reference
COPY --chown=anythingllm:nodejs package.json ./

# Create directories
RUN mkdir -p /app/server/storage/documents \
    /app/server/storage/vector-cache \
    /app/server/storage/lancedb \
    /app/collector/hotdir \
    /app/collector/storage/tmp \
    /app/server/logs \
    && chown -R anythingllm:nodejs /app \
    && chmod -R 755 /app

# Remove unnecessary files to reduce image size
RUN find /app -name "*.md" -delete && \
    find /app -name "*.txt" -delete && \
    find /app -name "*.log" -delete && \
    find /app -name ".git*" -delete && \
    find /app -name "test*" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /app -name "*.test.js" -delete && \
    find /app -name "*.spec.js" -delete

# Environment variables
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
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

EXPOSE ${PORT:-3001}

# Copy entrypoint
COPY --chown=anythingllm:nodejs docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

USER anythingllm

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD node -e "require('http').get('http://localhost:${PORT:-3001}/api/ping', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

ENTRYPOINT ["./docker-entrypoint.sh"]