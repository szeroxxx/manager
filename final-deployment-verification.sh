#!/bin/bash

# Company Management System - Final Deployment Verification Script
# This script validates the entire deployment configuration before going live

set -e

echo "=========================================="
echo "🚀 Company Management System Deployment Verification"
echo "=========================================="
echo "VPS IP: 72.61.173.90:4200"
echo "Backend API: http://72.61.173.90:5000"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Function to check if a file exists
check_file() {
    if [ -f "$1" ]; then
        print_status "File exists: $1"
        return 0
    else
        print_error "File missing: $1"
        return 1
    fi
}

# Function to check if a command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        print_status "Command available: $1"
        return 0
    else
        print_error "Command missing: $1"
        return 1
    fi
}

# Function to validate YAML syntax
validate_yaml() {
    if command -v yq >/dev/null 2>&1; then
        if yq eval '.' "$1" >/dev/null 2>&1; then
            print_status "YAML syntax valid: $1"
            return 0
        else
            print_error "YAML syntax invalid: $1"
            return 1
        fi
    else
        print_warning "yq not available, skipping YAML validation for $1"
        return 0
    fi
}

# Function to validate JSON syntax
validate_json() {
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$1" >/dev/null 2>&1; then
            print_status "JSON syntax valid: $1"
            return 0
        else
            print_error "JSON syntax invalid: $1"
            return 1
        fi
    else
        print_warning "jq not available, skipping JSON validation for $1"
        return 0
    fi
}

# Function to check environment variables
check_env_vars() {
    local file="$1"
    local required_vars=("$2")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^$var=" "$file"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -eq 0 ]; then
        print_status "All required environment variables present in $file"
        return 0
    else
        print_error "Missing environment variables in $file: ${missing_vars[*]}"
        return 1
    fi
}

# Function to validate IP configuration
validate_ip_config() {
    local ip="72.61.173.90"
    local files=("$1")
    local invalid_configs=()
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            if ! grep -q "$ip" "$file"; then
                invalid_configs+=("$file")
            fi
        fi
    done
    
    if [ ${#invalid_configs[@]} -eq 0 ]; then
        print_status "IP configuration ($ip) found in all files"
        return 0
    else
        print_error "IP configuration ($ip) missing in files: ${invalid_configs[*]}"
        return 1
    fi
}

# Function to check port availability
check_port_availability() {
    local port="$1"
    local service="$2"
    
    if ! netstat -tuln 2>/dev/null | grep -q ":$port "; then
        print_status "Port $port is available for $service"
        return 0
    else
        print_warning "Port $port is already in use for $service"
        return 1
    fi
}

# Function to validate Docker configuration
validate_docker_config() {
    if command -v docker-compose >/dev/null 2>&1; then
        if docker-compose -f docker-compose.vps.yml config >/dev/null 2>&1; then
            print_status "Docker Compose configuration is valid"
            return 0
        else
            print_error "Docker Compose configuration is invalid"
            return 1
        fi
    else
        print_warning "Docker Compose not available, skipping validation"
        return 0
    fi
}

# Function to check security configurations
check_security_configs() {
    local issues=()
    
    # Check for default secrets
    if grep -q "your-super-secret-jwt-key" docker-compose.vps.yml; then
        issues+=("Default JWT secret in docker-compose.vps.yml")
    fi
    
    if grep -q "your-super-secret-jwt-key" backend/.env.vps; then
        issues+=("Default JWT secret in backend/.env.vps")
    fi
    
    # Check for weak database password
    if grep -q "postgres123" docker-compose.vps.yml; then
        issues+=("Weak database password in docker-compose.vps.yml")
    fi
    
    # Check for HTTP vs HTTPS
    if grep -q "http://" nginx-vps.conf && ! grep -q "https://" nginx-vps.conf; then
        issues+=("Using HTTP instead of HTTPS in nginx-vps.conf")
    fi
    
    if [ ${#issues[@]} -eq 0 ]; then
        print_status "Security configurations look good"
        return 0
    else
        print_warning "Security issues found: ${issues[*]}"
        return 1
    fi
}

# Function to generate deployment report
generate_report() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local report_file="deployment-verification-report-${timestamp}.txt"
    
    echo "==========================================" > "$report_file"
    echo "Company Management System Deployment Verification Report" >> "$report_file"
    echo "Generated: $(date)" >> "$report_file"
    echo "VPS IP: 72.61.173.90:4200" >> "$report_file"
    echo "==========================================" >> "$report_file"
    echo "" >> "$report_file"
    echo "Pre-deployment Checklist:" >> "$report_file"
    echo "- Docker and Docker Compose installed: $(command -v docker >/dev/null 2>&1 && echo 'YES' || echo 'NO')" >> "$report_file"
    echo "- Required ports available: $(check_port_availability 4200 'frontend' >/dev/null 2>&1 && echo 'YES' || echo 'NO')" >> "$report_file"
    echo "- Configuration files present: $(check_file docker-compose.vps.yml >/dev/null 2>&1 && echo 'YES' || echo 'NO')" >> "$report_file"
    echo "- Environment variables configured: $(check_file backend/.env.vps >/dev/null 2>&1 && echo 'YES' || echo 'NO')" >> "$report_file"
    echo "" >> "$report_file"
    echo "Configuration Summary:" >> "$report_file"
    echo "- Frontend URL: http://72.61.173.90:4200" >> "$report_file"
    echo "- Backend API: http://72.61.173.90:5000" >> "$report_file"
    echo "- Database: PostgreSQL on port 5432" >> "$report_file"
    echo "- Nginx: Port 80 and 4201" >> "$report_file"
    
    print_status "Deployment report generated: $report_file"
}

# Main verification function
main() {
    echo "Starting deployment verification..."
    echo ""
    
    local errors=0
    
    # 1. Check system requirements
    echo "📋 Checking system requirements..."
    check_command "docker" || ((errors++))
    check_command "docker-compose" || ((errors++))
    echo ""
    
    # 2. Check required files
    echo "📁 Checking required files..."
    check_file "docker-compose.vps.yml" || ((errors++))
    check_file "backend/.env.vps" || ((errors++))
    check_file "frontend/.env.vps" || ((errors++))
    check_file "nginx-vps.conf" || ((errors++))
    check_file "deploy-vps.sh" || ((errors++))
    check_file "vps-setup.sh" || ((errors++))
    echo ""
    
    # 3. Validate configurations
    echo "🔧 Validating configurations..."
    validate_docker_config || ((errors++))
    validate_yaml "docker-compose.vps.yml" || ((errors++))
    echo ""
    
    # 4. Check environment variables
    echo "🔐 Checking environment variables..."
    check_env_vars "backend/.env.vps" "DATABASE_URL JWT_SECRET NODE_ENV PORT CORS_ORIGIN" || ((errors++))
    check_env_vars "frontend/.env.vps" "NEXT_PUBLIC_API_URL NODE_ENV" || ((errors++))
    echo ""
    
    # 5. Validate IP configuration
    echo "🌐 Validating IP configuration..."
    validate_ip_config "docker-compose.vps.yml backend/.env.vps frontend/.env.vps nginx-vps.conf" || ((errors++))
    echo ""
    
    # 6. Check port availability
    echo "🔍 Checking port availability..."
    check_port_availability "4200" "frontend" || ((errors++))
    check_port_availability "5000" "backend" || ((errors++))
    check_port_availability "5432" "database" || ((errors++))
    check_port_availability "80" "nginx" || ((errors++))
    echo ""
    
    # 7. Security check
    echo "🔒 Security configuration check..."
    check_security_configs || ((errors++))
    echo ""
    
    # 8. Generate report
    echo "📊 Generating deployment report..."
    generate_report
    echo ""
    
    # Final summary
    echo "=========================================="
    if [ $errors -eq 0 ]; then
        print_status "🎉 DEPLOYMENT VERIFICATION PASSED!"
        echo "Your VPS deployment configuration is ready."
        echo "Next steps:"
        echo "1. Upload all files to your VPS"
        echo "2. Run: ./vps-setup.sh"
        echo "3. Run: ./deploy-vps.sh"
        echo "4. Access your application at: http://72.61.173.90:4200"
    else
        print_error "❌ DEPLOYMENT VERIFICATION FAILED!"
        echo "Found $errors issues that need to be resolved."
        echo "Please fix the issues above before proceeding with deployment."
        exit 1
    fi
    echo "=========================================="
}

# Run the verification
main "$@"