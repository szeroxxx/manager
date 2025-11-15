# Build stage
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with legacy peer deps and proper error handling
RUN npm cache clean --force && \
    npm ci --prefer-offline --no-audit --legacy-peer-deps 2>&1 || \
    npm install --legacy-peer-deps 2>&1 || \
    (echo "Dependency installation failed" && exit 1)

# Copy source code
COPY . .

# Build the application with error handling
RUN echo "Starting Next.js build process..." && \
    npm run build 2>&1 || \
    (echo "Build failed with exit code: $?" && ls -la && ls -la node_modules 2>/dev/null || echo "node_modules not found" && exit 1)

# Production image
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy built application from builder
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Change ownership to nextjs user
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start the application
CMD ["node", "server.js"]