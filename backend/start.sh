#!/bin/sh

# Startup script for backend container
set -e

echo "Starting backend container..."

# Generate Prisma client if needed
echo "Checking Prisma client..."
npx prisma generate || echo "Prisma client generation failed, continuing..."

# Run database migrations with retry logic
echo "Running database migrations..."
MAX_RETRIES=30
RETRY_COUNT=0

until npx prisma migrate deploy; do
  RETRY_COUNT=$((RETRY_COUNT+1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Error: Migration failed after $MAX_RETRIES attempts."
    exit 1
  fi
  echo "Migration failed, retrying in 2 seconds... ($RETRY_COUNT/$MAX_RETRIES)"
  sleep 2
done

# Run database seeding
echo "Running database seeding..."
npx prisma db seed || echo "Database seeding failed, but continuing..."

# Start the application
echo "Starting Node.js application..."
exec node dist/index.js