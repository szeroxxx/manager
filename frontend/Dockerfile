# Use Node.js 18 Alpine as base image
FROM node:18-alpine AS deps

# Install dependencies only when needed
FROM deps AS builder
WORKDIR /app

# Copy package files
COPY package*.json ./

# Clean install dependencies with better error handling
RUN npm cache clean --force && \
    rm -rf node_modules package-lock.json && \
    npm install --verbose --legacy-peer-deps --no-optional

# Copy source code
COPY . .

# Build the application with detailed error handling
RUN echo "Starting build process..." && \
    npm run build || (echo "Build failed - checking directory structure:" && \
    ls -la && \
    echo "Checking node_modules:" && \
    ls -la node_modules/ 2>/dev/null || echo "node_modules not found" && \
    echo "Build error details:" && \
    exit 1)

# Production image, copy all the files and run next
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built application
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start the application
CMD ["node", "server.js"]