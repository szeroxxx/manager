# Hostinger Docker Deployment - Complete Fix Guide

## Issues Identified & Fixed

### 1. **Backend Dockerfile Build Failure** ❌→✅
**Original Error:** `exit code: 2` at `npm run build`

**Root Causes:**
- Missing proper dependency installation
- No error handling in build stage
- Incorrect Prisma client generation timing
- Multiple CMD/HEALTHCHECK instructions

**Fixes Applied:**
- Changed `npm ci` to separate production and dev dependencies: `npm ci --only=production && npm ci --only=dev`
- Added comprehensive error handling and logging
- Consolidated build commands with proper sequencing
- Removed duplicate EXPOSE and HEALTHCHECK instructions
- Added proper exit codes for troubleshooting

### 2. **Frontend Dockerfile Build Issues** ❌→✅
**Issues:**
- Redundant base image setup
- Verbose installation without fallbacks
- Incorrect health check endpoint

**Fixes Applied:**
- Streamlined build stage with single FROM
- Added legacy-peer-deps flag for compatibility
- Implemented proper fallback installation
- Fixed health check to use root path instead of non-existent `/api/health`
- Added proper ownership changes to nextjs user

### 3. **Docker Compose Configuration** ⚠️→✅
**Issues:**
- Deprecated `version: '3.8'` attribute (Hostinger warning)
- Incorrect frontend health check endpoint
- Missing start-period in health checks

**Fixes Applied:**
- Removed obsolete `version` field
- Updated all health checks with proper start periods
- Corrected frontend health check to root endpoint

---

## Key Changes by File

### Backend Dockerfile
```dockerfile
# IMPROVED: Separated dependency installation
RUN npm ci --only=production && \
    npm ci --only=dev

# IMPROVED: Better error handling
RUN npm run build 2>&1 && echo "Build completed successfully" || (echo "Build failed with exit code: $?" && exit 1)

# IMPROVED: Production stage includes health check and proper CMD
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', ...).on('error', () => process.exit(1))"
CMD ["node", "dist/index.js"]
```

### Frontend Dockerfile
```dockerfile
# IMPROVED: Consolidated build setup
FROM node:18-alpine AS builder

# IMPROVED: Better dependency installation with fallback
RUN npm ci --prefer-offline --no-audit --legacy-peer-deps 2>&1 || \
    npm install --legacy-peer-deps 2>&1 || \
    (echo "Dependency installation failed" && exit 1)

# IMPROVED: Proper health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', ...).on('error', () => process.exit(1))"
```

### Docker Compose
```yaml
# REMOVED: obsolete version field
# version: '3.8'  ← DELETED

# IMPROVED: Fixed frontend health check
healthcheck:
  test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"]
  interval: 30s
  timeout: 10s
  retries: 5
```

---

## Pre-Deployment Checklist

### ✅ Configuration Review
- [ ] All sensitive credentials (passwords, secrets) in docker-compose.yml should be replaced with strong values
- [ ] API URLs point to correct VPS IP address (currently: `http://72.61.173.90:5000`)
- [ ] Database URL matches PostgreSQL service name and credentials
- [ ] CORS origin matches your frontend domain

### ✅ Environment Setup
- [ ] Backend requires `prisma generate` to succeed (depends on DATABASE_URL)
- [ ] Frontend requires `NEXT_PUBLIC_API_URL` to be set correctly
- [ ] Both services have proper restart policies: `unless-stopped`

### ✅ Health Checks
- [ ] Backend health check: `GET http://localhost:5000/health`
- [ ] Frontend health check: `GET http://localhost:3000`
- [ ] PostgreSQL health check: `pg_isready -U postgres`

### ✅ Port Mappings
- [ ] PostgreSQL: `5432` (internal) → no external mapping required
- [ ] Backend API: `5000` (internal) → `5000` (external)
- [ ] Frontend: `3000` (internal) → `4200` (external)
- [ ] Nginx: `80` and `4201` (optional reverse proxy)

### ✅ Volume Persistence
- [ ] PostgreSQL data: `postgres_data:/var/lib/postgresql/data`
- [ ] Backend uploads: `./backend/uploads:/app/uploads`
- [ ] Database init script: `./init.sql` (must exist if referenced)

---

## Deployment Steps for Hostinger

### Step 1: Prepare Files
1. Ensure all files are committed to GitHub
2. Verify `docker-compose.yml` is in repository root
3. Check that `init.sql` exists (if database initialization needed)

### Step 2: Deploy via Hostinger Docker Manager
1. Go to Hostinger Docker Manager
2. Click "Compose" section
3. Paste this URL: `https://raw.githubusercontent.com/szeroxxx/manager/refs/heads/main/docker-compose.yml`
4. Enter Project Name: `company-management`
5. Click "Deploy"

### Step 3: Monitor Deployment
1. Watch build logs for errors
2. Verify all services start successfully
3. Check health checks pass (should take 30-60 seconds)
4. Access frontend at: `http://your-vps-ip:4200`
5. Test backend at: `http://your-vps-ip:5000/api/docs` (if Swagger is configured)

### Step 4: Post-Deployment Verification
```bash
# SSH into Hostinger VPS
docker ps                    # Verify all containers running
docker logs company-management-backend      # Check backend logs
docker logs company-management-frontend     # Check frontend logs
docker logs company-management-db           # Check database logs

# Test endpoints
curl http://localhost:5000/health          # Should return 200
curl http://localhost:3000                 # Should return HTML
```

---

## Common Issues & Solutions

### Issue: "npm run build" still fails
**Solution:**
- Check if `src/` directory exists and is properly copied
- Verify `tsconfig.json` configuration is correct
- Ensure all TypeScript dependencies are in `package.json`
- Run locally first: `npm ci && npm run build`

### Issue: Frontend build succeeds but app doesn't start
**Solution:**
- Verify `next.config.js` has `output: 'standalone'`
- Check `.next/standalone/server.js` exists
- Ensure environment variables are set in docker-compose.yml

### Issue: Database connection fails
**Solution:**
- Verify PostgreSQL is healthy first: `docker logs company-management-db`
- Check DATABASE_URL format is correct
- Ensure Prisma migrations run: `npx prisma migrate deploy`

### Issue: Health checks fail initially then pass
**Solution:**
- This is normal! `start-period` is set to allow services to start
- If they never pass, check logs for application errors

---

## Performance Tips

1. **Reduce image size:**
   - Already using Alpine Linux (small base)
   - Removing build dependencies in production stage

2. **Faster builds:**
   - `npm ci` is faster than `npm install`
   - Using `--prefer-offline` flag

3. **Better resource usage:**
   - Non-root users for security
   - Proper restart policies
   - Health checks for automatic recovery

---

## Security Recommendations

⚠️ **IMPORTANT**: Before deploying to production:

1. Change all hardcoded secrets in `docker-compose.yml`:
   - `POSTGRES_PASSWORD`
   - `JWT_SECRET`
   - `JWT_REFRESH_SECRET`

2. Use strong passwords (min 32 characters):
   ```bash
   openssl rand -base64 32  # Generate random secret
   ```

3. Update API URLs to use HTTPS when available

4. Consider using Docker secrets instead of environment variables

---

## Testing Commands

```bash
# Test backend build locally
cd backend
npm ci
npm run build

# Test frontend build locally
cd ../frontend
npm ci
npm run build

# Test docker build
docker build -t manager-backend ./backend
docker build -t manager-frontend ./frontend

# Test docker-compose
docker-compose up --build
```

---

## Need More Help?

- Check backend logs: `docker logs company-management-backend`
- Check frontend logs: `docker logs company-management-frontend`
- Check database logs: `docker logs company-management-db`
- Review Docker build output for specific errors

**Updated:** November 15, 2025
