# syntax=docker/dockerfile:1.7

# =============================================================================
# Builder stage
# =============================================================================

# TODO(step-4a)
FROM node:20-slim AS builder

WORKDIR /app

# TODO(step-4b)
COPY app/package.json app/package-lock.json ./
RUN npm ci --omit=dev
# security fix: patched proxy-addr (CVE-2026-90711) without editing app/
RUN npm install proxy-addr@2.0.8 --omit=dev --no-save

# TODO(step-4c)
COPY app/ ./

# =============================================================================
# Runtime stage
# =============================================================================

# TODO(step-4d)
FROM node:20-slim

WORKDIR /app

# security fix: patch Debian packages (gnutls, perl)
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# TODO(step-4e)
COPY --from=builder /app /app

# security fix: npm (and its bundled tar) is not needed at runtime
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

ENV NODE_ENV=production
EXPOSE 3000

# TODO(step-4f)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
CMD node -e "require('http').get('http://localhost:3000/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"

# TODO(step-4g)
CMD ["node", "src/index.js"]
