# STAGE 1: Builder

FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app
COPY app/package*.json ./
RUN npm ci
COPY app/ .
RUN npm test

# STAGE 2: Production
# Minimal image with only production dependencies

FROM node:18-alpine AS production
WORKDIR /app
ENV NODE_ENV=production

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy package files
COPY app/package*.json ./

# Install only production dependencies
RUN npm ci --only=production                                                    
COPY --from=builder /app/server.js .
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "server.js"]