# Ultra-Fast Single-Stage Railway Dockerfile (Speed Optimized)
FROM node:20-alpine

# Install all dependencies in one layer for speed
RUN apk add --no-cache \
    python3 py3-pip make g++ \
    cairo-dev jpeg-dev pango-dev musl-dev \
    giflib-dev pixman-dev pangomm-dev \
    libjpeg-turbo-dev freetype-dev pkgconfig \
    bash curl git sqlite chromium \
    ttf-dejavu fontconfig \
    && rm -rf /var/cache/apk/*

# Speed optimizations
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1
ENV npm_config_build_from_source=false
ENV npm_config_cache_max=0
ENV NODE_ENV=production

# Create user early
RUN addgroup -g 1001 -S nodejs && adduser -S anythingllm -u 1001 -G nodejs

WORKDIR /app

# Copy all package.json files at once
COPY package.json ./
COPY frontend/package.json ./frontend/
COPY server/package.json ./server/
COPY collector/package.json ./collector/

# Install all dependencies in parallel using single yarn command
RUN yarn install --network-timeout 300000 --prefer-offline --silent && \
    cd frontend && yarn install --network-timeout 300000 --prefer-offline --silent && \
    cd ../server && yarn install --production --network-timeout 300000 --prefer-offline --silent && \
    cd ../collector && yarn install --production --network-timeout 300000 --prefer-offline --silent && \
    cd ..

# Copy all source code at once
COPY frontend/ ./frontend/
COPY server/ ./server/
COPY collector/ ./collector/
COPY docker-entrypoint.sh ./

# Fix icon issue and build frontend in one step
WORKDIR /app/frontend
RUN sed -i 's/FolderNotch/Folder/g' src/components/Modals/ManageWorkspace/Documents/Directory/FolderRow/index.jsx && \
    NODE_OPTIONS="--max-old-space-size=2048" yarn build --silent

# Generate Prisma client
WORKDIR /app/server
RUN npx prisma generate --schema=./prisma/schema.prisma

# Setup application structure
WORKDIR /app
RUN mkdir -p server/public && cp -r frontend/dist/* server/public/ && \
    mkdir -p server/storage/documents server/storage/vector-cache server/storage/lancedb \
             collector/hotdir collector/storage/tmp server/logs && \
    chmod +x docker-entrypoint.sh && \
    chown -R anythingllm:nodejs /app && \
    chmod -R 755 /app

# Aggressive cleanup to reduce size
RUN rm -rf frontend/node_modules frontend/dist frontend/src && \
    find server/node_modules -name "*.md" -delete && \
    find collector/node_modules -name "*.md" -delete && \
    find . -name "test*" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find . -name "*.test.js" -delete 2>/dev/null || true && \
    yarn cache clean --silent

# Environment variables
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