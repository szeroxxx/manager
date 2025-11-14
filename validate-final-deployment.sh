#!/bin/bash

# Final Deployment Validation Script
# This script validates that all fixes are properly applied

set -e

echo "=========================================="
echo "🔍 FINAL DEPLOYMENT VALIDATION"
echo "=========================================="
echo "Validating all fixes are properly applied..."
echo "VPS IP: 72.61.173.90:4200"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Function to check file content
check_file_content() {
    local file="$1"
    local pattern="$2"
    local description="$3"
    
    if grep -q "$pattern" "$file"; then
        print_status "$description"
        return 0
    else
        print_error "$description"
        return 1
    fi
}

# Function to validate Docker Compose
check_docker_compose() {
    print_status "Validating Docker Compose configuration..."
    if docker-compose config >/dev/null 2>&1; then
        print_status "Docker Compose configuration is valid"
        return 0
    else
        print_error "Docker Compose configuration is invalid"
        return 1
    fi
}

# Main validation function
main() {
    local errors=0
    
    echo "1. Checking Backend Dockerfile fixes..."
    check_file_content "backend/Dockerfile" "RUN npm ci" "Backend installs all dependencies"
    check_file_content "backend/Dockerfile" "RUN npx prisma generate" "Backend generates Prisma client"
    check_file_content "backend/Dockerfile" "COPY prisma ./prisma" "Backend copies Prisma schema"
    echo ""
    
    echo "2. Checking Frontend package.json versions..."
    check_file_content "frontend/package.json" '"next": "14.0.4"' "Frontend Next.js version is compatible"
    check_file_content "frontend/package.json" '"react": "^18.2.0"' "Frontend React version is compatible"
    check_file_content "frontend/package.json" '"react-dom": "^18.2.0"' "Frontend ReactDOM version is compatible"
    echo ""
    
    echo "3. Checking Frontend Next.js configuration..."
    check_file_content "frontend/next.config.ts" "output: 'standalone'" "Frontend has standalone output"
    check_file_content "frontend/next.config.ts" "images:.*unoptimized: true" "Frontend images are unoptimized"
    echo ""
    
    echo "4. Checking Security configurations..."
    check_file_content "docker-compose.yml" "vps-production-jwt-secret-key-2025" "JWT secrets updated"
    check_file_content "docker-compose.yml" "vps-secure-db-password-2025-company-manager" "Database password updated"
    check_file_content "docker-compose.yml" "CORS_ORIGIN: http://72.61.173.90:4200" "CORS configured for VPS"
    echo ""
    
    echo "5. Checking VPS configuration..."
    check_file_content "docker-compose.yml" '"4200:3000"' "Frontend port mapped to 4200"
    check_file_content "docker-compose.yml" '"5000:5000"' "Backend port mapped to 5000"
    check_file_content "docker-compose.yml" "restart: unless-stopped" "Restart policies configured"
    echo ""
    
    echo "6. Validating Docker Compose syntax..."
    check_docker_compose
    echo ""
    
    echo "7. Checking critical files exist..."
    for file in "docker-compose.yml" "backend/Dockerfile" "frontend/Dockerfile" "nginx-vps.conf" "init.sql"; do
        if [ -f "$file" ]; then
            print_status "File exists: $file"
        else
            print_error "File missing: $file"
            ((errors++))
        fi
    done
    echo ""
    
    # Final summary
    echo "=========================================="
    if [ $errors -eq 0 ]; then
        print_status "🎉 ALL VALIDATIONS PASSED!"
        echo "Your deployment is ready for GitHub."
        echo ""
        echo "Next steps:"
        echo "1. Run: ./push-to-github.sh"
        echo "2. Deploy via Hostinger Docker Manager"
        echo "3. Access your app at: http://72.61.173.90:4200"
        echo ""
        echo "✅ DEPLOYMENT STATUS: READY TO GO!"
    else
        print_error "❌ VALIDATION FAILED!"
        echo "Found $errors issues that need to be resolved."
        echo "Please fix the issues above before deployment."
        exit 1
    fi
    echo "=========================================="
}

# Run validation
main "$@"