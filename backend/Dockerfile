# Use Node.js 18 Alpine as base image
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with proper error handling
RUN npm ci

# Copy Prisma schema and source code
COPY prisma ./prisma
COPY tsconfig.json ./
COPY src ./src

# Set environment variable for Prisma generation (temporary)
ENV DATABASE_URL="postgresql://user:password@localhost:5432/temp_db"

# Generate Prisma client with error handling
RUN npx prisma generate 2>&1 || true

# Build the application
RUN npm run build

# Production stage
FROM node:18-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app directory
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S backend -u 1001

# Copy built application from builder stage
COPY --from=builder --chown=backend:nodejs /app/dist ./dist
COPY --from=builder --chown=backend:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=backend:nodejs /app/package*.json ./
COPY --from=builder --chown=backend:nodejs /app/prisma ./prisma

# Set environment variable for Prisma generation (will be overridden by docker-compose)
ENV DATABASE_URL="postgresql://user:password@localhost:5432/temp_db" \
    NODE_ENV=production

# Generate Prisma client for production with error handling
RUN npx prisma generate 2>&1 || true

# Create uploads directory
RUN mkdir -p uploads && chown backend:nodejs uploads

# Copy start script
COPY start.sh ./
RUN sed -i 's/\r$//' start.sh
RUN chmod +x start.sh

# Switch to non-root user
USER backend

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start the application
CMD ["./start.sh"]