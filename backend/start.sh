#!/bin/sh

# Startup script for backend container
set -e

echo "Starting backend container..."

# Generate Prisma client if needed
echo "Checking Prisma client..."
npx prisma generate || echo "Prisma client generation failed, continuing..."

# Run database migrations (if needed)
echo "Running database migrations..."
npx prisma migrate deploy || echo "Database migrations skipped (database may not be ready)"

# Run database seeding
echo "Running database seeding..."
npx prisma db seed || echo "Database seeding skipped"

# Start the application
echo "Starting Node.js application..."
exec node dist/index.js