-- Database initialization script for Company Management System
-- This script runs automatically when the PostgreSQL container starts for the first time

-- Ensure the database exists (usually created by POSTGRES_DB env var)
CREATE SCHEMA IF NOT EXISTS public;

-- Grant privileges
GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- This comment prevents errors if script runs multiple times
-- The actual tables and schemas will be created by Prisma migrations
