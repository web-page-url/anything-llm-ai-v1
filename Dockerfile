# ULTRA-FAST Railway Build - Under 8 Minutes, Under 4GB
FROM node:20-alpine

# Install system dependencies (optimized for speed)
RUN apk add --no-cache --virtual .build-deps \
    python3 py3-pip make g++ pkgconfig \
    cairo-dev jpeg-dev pango-dev musl-dev \
    giflib-dev pixman-dev pangomm-dev \
    libjpeg-turbo-dev freetype-dev git && \
    apk add --no-cache \
    python3 cairo jpeg pango musl giflib pixman \
    pangomm libjpeg-turbo freetype ttf-dejavu \
    fontconfig bash curl sqlite chromium

# Speed optimizations
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1
ENV npm_config_build_from_source=false
ENV YARN_CACHE_FOLDER=/tmp/yarn-cache

# Create user
RUN addgroup -g 1001 -S nodejs && adduser -S anythingllm -u 1001 -G nodejs

WORKDIR /app

# Copy package files
COPY package.json ./
COPY frontend/package.json ./frontend/
COPY server/package.json ./server/
COPY collector/package.json ./collector/

# PARALLEL dependency installation for speed
RUN mkdir -p /tmp/yarn-cache && \
    (cd frontend && NODE_ENV=development yarn install --cache-folder /tmp/yarn-cache --network-timeout 180000 --silent &) && \
    (cd server && yarn install --cache-folder /tmp/yarn-cache --network-timeout 180000 --silent &) && \
    (cd collector && yarn install --production --cache-folder /tmp/yarn-cache --network-timeout 180000 --silent &) && \
    wait

# Add missing frontend dependencies
WORKDIR /app/frontend
RUN yarn add regenerator-runtime core-js --silent

# Copy source code
WORKDIR /app
COPY frontend/ ./frontend/
COPY server/ ./server/
COPY collector/ ./collector/
COPY docker-entrypoint.sh ./

# Fix icon and build frontend (optimized)
WORKDIR /app/frontend
RUN sed -i 's/FolderNotch/Folder/g' src/components/Modals/ManageWorkspace/Documents/Directory/FolderRow/index.jsx && \
    NODE_ENV=production NODE_OPTIONS="--max-old-space-size=1536" yarn build --silent

# Skip Prisma generation - will be done at runtime in entrypoint script

# Setup application structure
WORKDIR /app
RUN mkdir -p server/public && cp -r frontend/dist/* server/public/ && \
    mkdir -p server/storage/documents server/storage/vector-cache server/storage/lancedb \
             collector/hotdir collector/storage/tmp server/logs && \
    chmod +x docker-entrypoint.sh && \
    chown -R anythingllm:nodejs /app && chmod -R 755 /app

# AGGRESSIVE cleanup to reduce size under 4GB
RUN rm -rf frontend/node_modules frontend/src frontend/public frontend/.git* frontend/dist && \
    find server/node_modules -type f -name "*.md" -delete && \
    find server/node_modules -type f -name "*.txt" -delete && \
    find server/node_modules -type f -name "*.map" -delete && \
    find server/node_modules -type d -name "test*" -exec rm -rf {} + 2>/dev/null || true && \
    find server/node_modules -type d -name "__tests__" -exec rm -rf {} + 2>/dev/null || true && \
    find server/node_modules -type d -name "docs" -exec rm -rf {} + 2>/dev/null || true && \
    find collector/node_modules -type f -name "*.md" -delete && \
    find collector/node_modules -type f -name "*.txt" -delete && \
    find collector/node_modules -type f -name "*.map" -delete && \
    find collector/node_modules -type d -name "test*" -exec rm -rf {} + 2>/dev/null || true && \
    find collector/node_modules -type d -name "__tests__" -exec rm -rf {} + 2>/dev/null || true && \
    find collector/node_modules -type d -name "docs" -exec rm -rf {} + 2>/dev/null || true && \
    rm -rf /tmp/yarn-cache /root/.yarn-cache /root/.npm && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*

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

EXPOSE ${PORT:-3001}

USER anythingllm

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD node -e "require('http').get('http://localhost:${PORT:-3001}/api/ping', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

ENTRYPOINT ["./docker-entrypoint.sh"]