@echo off
echo ==========================================
echo 🚀 Company Management System - GitHub Deployment
echo ==========================================
echo VPS IP: 72.61.173.90:4200
echo ==========================================

echo Checking Git repository...
git status

echo.
echo Adding all files to git...
git add .

echo.
echo Committing changes...
git commit -m "Final deployment: Fix Docker build issues and VPS configuration

- Fixed backend Dockerfile with TypeScript dependencies and Prisma generation
- Updated frontend package.json with compatible Next.js 14.0.4 and React 18.2.0
- Configured Next.js standalone mode for Docker deployment
- Updated docker-compose.yml with VPS IP 72.61.173.90 and secure credentials
- Added comprehensive deployment documentation
- All Docker build issues resolved"

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo ==========================================
echo 🎉 DEPLOYMENT READY!
echo ==========================================
echo.
echo Next steps:
echo 1. Go to Hostinger VPS Docker Manager
echo 2. Use this URL: https://raw.githubusercontent.com/szeroxxx/manager/main/docker-compose.yml
echo 3. Project name: company-management-system
echo 4. Click Deploy
echo.
echo Your app will be available at: http://72.61.173.90:4200
echo ==========================================

pause