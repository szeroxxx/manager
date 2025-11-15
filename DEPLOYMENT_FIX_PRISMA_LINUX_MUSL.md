# Deployment Fix: Prisma Linux-MUSL Binary Target

## Problem

The Docker deployment on Hostinger was failing with the following error:

```
PrismaClientInitializationError: Prisma Client could not locate the Query Engine for runtime "linux-musl".

This happened because Prisma Client was generated for "linux-musl-openssl-3.0.x", but the actual deployment required "linux-musl".
```

## Root Cause

The backend's Prisma schema did not specify `linux-musl` as a binary target. When the Docker image is built on Alpine Linux (which uses musl instead of glibc), Prisma needs to download and use the correct query engine binary. The schema was missing this configuration.

## Solution

Updated `backend/prisma/schema.prisma` to include the `linux-musl` binary target:

```prisma
generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "linux-musl"]
}
```

### Changes Made:

1. **File**: `backend/prisma/schema.prisma`
   - Added `binaryTargets = ["native", "linux-musl"]` to the generator block
   - `"native"` - For local development (Windows/Linux)
   - `"linux-musl"` - For Docker deployment (Alpine Linux)

2. **Regenerated**: Package dependencies and Prisma client

3. **Committed & Pushed** to `main` branch on GitHub

## How to Deploy Now

1. **Option A**: Re-deploy using Hostinger Docker Manager with the same docker-compose.yml URL
   - GitHub will pull the latest code with the fix
   - Docker build will download the correct Prisma engines for linux-musl
   - The backend container should start successfully

2. **Option B**: If you need to redeploy from scratch:
   ```bash
   # In Hostinger Docker Manager, use:
   # Project URL: https://raw.githubusercontent.com/szeroxxx/manager/refs/heads/main/docker-compose.yml
   # Then click "Deploy"
   ```

## Why This Works

- When Prisma generates the client during Docker build, it will now download the `linux-musl` binary
- The Docker image runs on Alpine Linux (which uses musl libc)
- This ensures the query engine binary matches the container's runtime environment
- The health check will pass and the container will remain running

## Verification

After redeployment, check the logs for:
```
🚀 Server running on port 5000
✅ Database connection successful
📚 API Documentation available at http://localhost:5000/api-docs
```

Without the Prisma initialization error.

## Files Changed

- `backend/prisma/schema.prisma` - Added binaryTargets configuration
- `backend/package.json` - Updated dependencies
- `backend/package-lock.json` - Updated lock file

## Git Commit

```
Commit: 6e5777b
Message: Fix: Add linux-musl binary target to Prisma schema for Docker deployment
```

---

**Status**: ✅ READY FOR REDEPLOYMENT
