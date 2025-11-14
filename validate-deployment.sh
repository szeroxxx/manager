#!/bin/bash

# Deployment Validation Script for Company Management System
# This script validates the deployment configuration

set -e

echo "🔍 Validating Company Management System Deployment Configuration"
echo "================================================================="
echo ""

# Configuration
VPS_IP="72.61.173.90"
ERRORS=0
WARNINGS=0

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check file existence
check_file() {
    if [ -f "$1" ]; then
        print_success "File exists: $1"
    else
        print_error "File missing: $1"
    fi
}

# Function to check directory existence
check_directory() {
    if [ -d "$1" ]; then
        print_success "Directory exists: $1"
    else
        print_error "Directory missing: $1"
    fi
}

# Function to validate JSON/JS syntax
check_js_syntax() {
    if command -v node >/dev/null 2>&1; then
        if node -c "$1" 2>/dev/null; then
            print_success "Valid JavaScript syntax: $1"
        else
            print_error "Invalid JavaScript syntax: $1"
        fi
    else
        print_warning "Node.js not found, skipping syntax check for: $1"
    fi
}

# Function to validate YAML syntax
check_yaml_syntax() {
    if command -v python3 >/dev/null 2>&1; then
        if python3 -c "import yaml; yaml.safe_load(open('$1'))" 2>/dev/null; then
            print_success "Valid YAML syntax: $1"
        else
            print_error "Invalid YAML syntax: $1"
        fi
    else
        print_warning "Python3 not found, skipping YAML syntax check for: $1"
    fi
}

# Function to check environment variables
check_env_variables() {
    local env_file="$1"
    local required_vars=("$2")
    
    if [ -f "$env_file" ]; then
        for var in "${required_vars[@]}"; do
            if grep -q "^$var=" "$env_file"; then
                local value=$(grep "^$var=" "$env_file" | cut -d'=' -f2-)
                if [ -n "$value" ] && [ "$value" != '""' ]; then
                    print_success "Environment variable set: $var"
                else
                    print_warning "Environment variable empty: $var"
                fi
            else
                print_error "Environment variable missing: $var"
            fi
        done
    else
        print_error "Environment file not found: $env_file"
    fi
}

# Start validation
echo "📁 Checking File Structure..."
echo "--------------------------------"

# Check main files
check_file "docker-compose.vps.yml"
check_file "nginx-vps.conf"
check_file "deploy-vps.sh"
check_file "vps-setup.sh"
check_file "VPS_DEPLOYMENT_GUIDE.md"

# Check backend files
check_directory "backend"
check_file "backend/Dockerfile"
check_file "backend/package.json"
check_file "backend/.env.vps"
check_directory "backend/src"
check_directory "backend/prisma"

# Check frontend files
check_directory "frontend"
check_file "frontend/Dockerfile"
check_file "frontend/package.json"
check_file "frontend/.env.vps"
check_directory "frontend/src"

echo ""
echo "🔧 Validating Configuration Files..."
echo "-------------------------------------"

# Validate docker-compose YAML
if [ -f "docker-compose.vps.yml" ]; then
    check_yaml_syntax "docker-compose.vps.yml"
    
    # Check for VPS IP in docker-compose
    if grep -q "$VPS_IP" docker-compose.vps.yml; then
        print_success "VPS IP ($VPS_IP) found in docker-compose.vps.yml"
    else
        print_error "VPS IP ($VPS_IP) not found in docker-compose.vps.yml"
    fi
fi

# Validate nginx configuration
if [ -f "nginx-vps.conf" ]; then
    if grep -q "$VPS_IP" nginx-vps.conf; then
        print_success "Nginx configuration contains VPS IP references"
    else
        print_warning "Nginx configuration may need IP-specific settings"
    fi
    
    # Check for required nginx settings
    if grep -q "listen 80" nginx-vps.conf; then
        print_success "Nginx HTTP configuration found"
    else
        print_error "Nginx HTTP configuration missing"
    fi
fi

echo ""
echo "🔐 Validating Environment Variables..."
echo "---------------------------------------"

# Backend environment variables
BACKEND_VARS=("DATABASE_URL" "JWT_SECRET" "JWT_REFRESH_SECRET" "NODE_ENV" "PORT" "CORS_ORIGIN")
check_env_variables "backend/.env.vps" "${BACKEND_VARS[@]}"

# Check CORS origin
if [ -f "backend/.env.vps" ]; then
    CORS_ORIGIN=$(grep "CORS_ORIGIN" backend/.env.vps | cut -d'=' -f2- | tr -d '"')
    if [[ "$CORS_ORIGIN" == *"$VPS_IP"* ]]; then
        print_success "CORS origin configured for VPS IP"
    else
        print_error "CORS origin not configured for VPS IP"
    fi
fi

# Frontend environment variables
FRONTEND_VARS=("NEXT_PUBLIC_API_URL" "NODE_ENV")
check_env_variables "frontend/.env.vps" "${FRONTEND_VARS[@]}"

# Check API URL
if [ -f "frontend/.env.vps" ]; then
    API_URL=$(grep "NEXT_PUBLIC_API_URL" frontend/.env.vps | cut -d'=' -f2- | tr -d '"')
    if [[ "$API_URL" == *"$VPS_IP"* ]]; then
        print_success "Frontend API URL configured for VPS"
    else
        print_error "Frontend API URL not configured for VPS"
    fi
fi

echo ""
echo "🐳 Validating Docker Configuration..."
echo "--------------------------------------"

# Check Docker images
if [ -f "docker-compose.vps.yml" ]; then
    # Check for required services
    if grep -q "postgres:" docker-compose.vps.yml; then
        print_success "PostgreSQL service configured"
    else
        print_error "PostgreSQL service missing"
    fi
    
    if grep -q "backend:" docker-compose.vps.yml; then
        print_success "Backend service configured"
    else
        print_error "Backend service missing"
    fi
    
    if grep -q "frontend:" docker-compose.vps.yml; then
        print_success "Frontend service configured"
    else
        print_error "Frontend service missing"
    fi
    
    if grep -q "nginx:" docker-compose.vps.yml; then
        print_success "Nginx service configured"
    else
        print_error "Nginx service missing"
    fi
    
    # Check port mappings
    if grep -q "4200:3000" docker-compose.vps.yml; then
        print_success "Frontend port mapping configured (4200)"
    else
        print_warning "Frontend port mapping may need verification"
    fi
    
    if grep -q "5000:5000" docker-compose.vps.yml; then
        print_success "Backend port mapping configured (5000)"
    else
        print_warning "Backend port mapping may need verification"
    fi
fi

echo ""
echo "🔑 Security Validation..."
echo "-------------------------"

# Check for default secrets
if [ -f "backend/.env.vps" ]; then
    JWT_SECRET=$(grep "JWT_SECRET" backend/.env.vps | cut -d'=' -f2- | tr -d '"')
    if [[ "$JWT_SECRET" == *"change-this-in-production"* ]] || [[ ${#JWT_SECRET} -lt 32 ]]; then
        print_warning "JWT secret appears to be default or too short"
    else
        print_success "JWT secret appears to be properly configured"
    fi
fi

# Check for health checks
if grep -q "healthcheck:" docker-compose.vps.yml; then
    print_success "Health checks configured"
else
    print_warning "Health checks not found in docker-compose"
fi

# Check for restart policies
if grep -q "restart: unless-stopped" docker-compose.vps.yml; then
    print_success "Restart policies configured"
else
    print_warning "Restart policies not found"
fi

echo ""
echo "📋 Deployment Readiness Summary"
echo "================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_success "🎉 DEPLOYMENT READY! All checks passed."
    echo ""
    echo "🚀 Ready to deploy with:"
    echo "   ./deploy-vps.sh"
    echo ""
    echo "🌐 Access URLs after deployment:"
    echo "   Frontend: http://$VPS_IP:4200"
    echo "   Backend API: http://$VPS_IP:5000"
    echo "   API Documentation: http://$VPS_IP:5000/api-docs"
elif [ $ERRORS -eq 0 ]; then
    print_warning "⚠️  DEPLOYMENT POSSIBLE with warnings."
    echo ""
    echo "🚀 You can proceed with deployment:"
    echo "   ./deploy-vps.sh"
    echo ""
    echo "⚠️  Please review warnings above before deploying."
else
    print_error "❌ DEPLOYMENT NOT READY - Errors found!"
    echo ""
    echo "🔧 Please fix the errors above before deploying."
    echo ""
    echo "📚 Common fixes:"
    echo "   - Ensure all required files are present"
    echo "   - Update environment variables with VPS IP"
    echo "   - Change default JWT secrets"
    echo "   - Verify docker-compose configuration"
fi

echo ""
echo "📖 For detailed deployment instructions, see:"
echo "   VPS_DEPLOYMENT_GUIDE.md"
echo ""

# Exit with appropriate code
if [ $ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi