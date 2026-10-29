# syntax=docker/dockerfile:1.7

# =============================================================================
# Builder stage
# =============================================================================

# TODO(step-4a)
FROM node:20.11-slim AS builder

WORKDIR /app

# TODO(step-4b)
COPY app/package.json app/package-lock.json ./
RUN npm ci --omit=dev

# TODO(step-4c)
COPY app/ ./

# =============================================================================
# Runtime stage
# =============================================================================

# TODO(step-4d)
FROM node:20.11-slim

WORKDIR /app

# TODO(step-4e)
COPY --from=builder /app /app

ENV NODE_ENV=production
EXPOSE 3000

# TODO(step-4f)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
CMD node -e "require('http').get('http://localhost:3000/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"

# TODO(step-4g)
CMD ["node", "src/index.js"]
