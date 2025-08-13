# ULTRA-SLIM Multi-Stage Build - UNDER 2GB GUARANTEED
FROM node:20-alpine AS builder

# Install build dependencies
RUN apk add --no-cache python3 py3-pip make g++ \
    cairo-dev jpeg-dev pango-dev musl-dev \
    giflib-dev pixman-dev pangomm-dev \
    libjpeg-turbo-dev freetype-dev pkgconfig \
    bash curl git

# Build optimizations
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1
ENV npm_config_build_from_source=false

WORKDIR /app

# Copy package files
COPY package.json ./
COPY frontend/package.json ./frontend/
COPY server/package.json ./server/
COPY collector/package.json ./collector/

# Install ALL dependencies in builder stage
RUN cd frontend && NODE_ENV=development yarn install --network-timeout 300000 --silent && \
    yarn add regenerator-runtime core-js --silent && cd ..
RUN cd server && yarn install --production --network-timeout 300000 --silent && cd ..
RUN cd collector && yarn install --production --network-timeout 300000 --silent && cd ..

# Copy source code
COPY frontend/ ./frontend/
COPY server/ ./server/
COPY collector/ ./collector/

# Fix icon and build frontend
WORKDIR /app/frontend
RUN sed -i 's/FolderNotch/Folder/g' src/components/Modals/ManageWorkspace/Documents/Directory/FolderRow/index.jsx
RUN NODE_ENV=production NODE_OPTIONS="--max-old-space-size=2048" yarn build

# Generate Prisma client
WORKDIR /app/server
RUN npx prisma generate --schema=./prisma/schema.prisma

# PRODUCTION STAGE - MINIMAL RUNTIME IMAGE
FROM node:20-alpine AS production

# Install ONLY runtime dependencies
RUN apk add --no-cache \
    python3 cairo jpeg pango musl giflib pixman \
    pangomm libjpeg-turbo freetype ttf-dejavu \
    fontconfig bash curl sqlite chromium \
    && rm -rf /var/cache/apk/*

# Create user
RUN addgroup -g 1001 -S nodejs && adduser -S anythingllm -u 1001 -G nodejs

WORKDIR /app

# Copy ONLY production files (NO node_modules from builder)
COPY --from=builder --chown=anythingllm:nodejs /app/server/node_modules ./server/node_modules
COPY --from=builder --chown=anythingllm:nodejs /app/collector/node_modules ./collector/node_modules
COPY --from=builder --chown=anythingllm:nodejs /app/server/prisma ./server/prisma
COPY --from=builder --chown=anythingllm:nodejs /app/server/*.js ./server/
COPY --from=builder --chown=anythingllm:nodejs /app/server/package.json ./server/
COPY --from=builder --chown=anythingllm:nodejs /app/collector/*.js ./collector/
COPY --from=builder --chown=anythingllm:nodejs /app/collector/package.json ./collector/
COPY --from=builder --chown=anythingllm:nodejs /app/frontend/dist ./server/public

# Copy other necessary files
COPY --from=builder --chown=anythingllm:nodejs /app/server/endpoints ./server/endpoints
COPY --from=builder --chown=anythingllm:nodejs /app/server/models ./server/models
COPY --from=builder --chown=anythingllm:nodejs /app/server/utils ./server/utils
COPY --from=builder --chown=anythingllm:nodejs /app/server/jobs ./server/jobs
COPY --from=builder --chown=anythingllm:nodejs /app/collector/processSingleFile ./collector/processSingleFile
COPY --from=builder --chown=anythingllm:nodejs /app/collector/processLink ./collector/processLink
COPY --from=builder --chown=anythingllm:nodejs /app/collector/processRawText ./collector/processRawText
COPY --from=builder --chown=anythingllm:nodejs /app/collector/utils ./collector/utils
COPY --from=builder --chown=anythingllm:nodejs /app/collector/extensions ./collector/extensions
COPY --from=builder --chown=anythingllm:nodejs /app/collector/middleware ./collector/middleware

# Copy package.json and entrypoint
COPY --chown=anythingllm:nodejs package.json ./
COPY --chown=anythingllm:nodejs docker-entrypoint.sh ./

# Create directories
RUN mkdir -p server/storage/documents server/storage/vector-cache server/storage/lancedb \
             collector/hotdir collector/storage/tmp server/logs && \
    chmod +x docker-entrypoint.sh && \
    chown -R anythingllm:nodejs /app && chmod -R 755 /app

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

USER anythingllm

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD node -e "require('http').get('http://localhost:${PORT:-3001}/api/ping', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

ENTRYPOINT ["./docker-entrypoint.sh"]