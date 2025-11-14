#!/bin/bash

# Company Management System - VPS Deployment Script
# This script deploys the application on your VPS server

set -e  # Exit on error

echo "🚀 Starting Company Management System VPS Deployment"
echo "=================================================="

# Configuration
VPS_IP="72.61.173.90"
PROJECT_NAME="company-management-system"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check system requirements
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check Docker
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check memory (minimum 2GB)
    MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$MEMORY_GB" -lt 2 ]; then
        print_warning "Less than 2GB RAM detected. This may cause performance issues."
    fi
    
    print_status "System requirements check completed."
}

# Function to create backup
create_backup() {
    if [ -d "postgres_data" ] || docker ps -a | grep -q "company-management"; then
        print_status "Creating backup of existing data..."
        mkdir -p "$BACKUP_DIR"
        
        # Backup database if container exists
        if docker ps -a | grep -q "company-management-db"; then
            docker exec company-management-db pg_dump -U postgres company_management > "$BACKUP_DIR/database_backup.sql" 2>/dev/null || true
        fi
        
        print_status "Backup created at: $BACKUP_DIR"
    fi
}

# Function to stop existing containers
stop_existing_containers() {
    print_status "Stopping existing containers..."
    
    # Stop and remove existing containers
    docker-compose -f docker-compose.vps.yml down --remove-orphans 2>/dev/null || true
    
    # Remove old containers if they exist
    docker stop company-management-db company-management-backend company-management-frontend company-management-nginx 2>/dev/null || true
    docker rm company-management-db company-management-backend company-management-frontend company-management-nginx 2>/dev/null || true
    
    print_status "Existing containers stopped and removed."
}

# Function to set up environment
setup_environment() {
    print_status "Setting up environment variables..."
    
    # Copy VPS environment files
    if [ -f "backend/.env.vps" ]; then
        cp backend/.env.vps backend/.env
        print_status "Backend environment configured."
    else
        print_error "backend/.env.vps not found. Please ensure VPS environment file exists."
        exit 1
    fi
    
    if [ -f "frontend/.env.vps" ]; then
        cp frontend/.env.vps frontend/.env.local
        print_status "Frontend environment configured."
    else
        print_error "frontend/.env.vps not found. Please ensure VPS environment file exists."
        exit 1
    fi
}

# Function to build and start services
build_and_start() {
    print_status "Building and starting services..."
    
    # Build the services
    print_status "Building Docker images..."
    docker-compose -f docker-compose.vps.yml build --no-cache
    
    # Start the services
    print_status "Starting services..."
    docker-compose -f docker-compose.vps.yml up -d
    
    print_status "Services started successfully."
}

# Function to wait for services
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for database
    print_status "Waiting for database..."
    timeout=60
    while ! docker exec company-management-db pg_isready -U postgres >/dev/null 2>&1; do
        sleep 2
        timeout=$((timeout - 2))
        if [ $timeout -le 0 ]; then
            print_error "Database failed to start within 60 seconds"
            exit 1
        fi
    done
    
    # Wait for backend
    print_status "Waiting for backend..."
    timeout=60
    while ! curl -f http://localhost:5000/health >/dev/null 2>&1; do
        sleep 2
        timeout=$((timeout - 2))
        if [ $timeout -le 0 ]; then
            print_error "Backend failed to start within 60 seconds"
            exit 1
        fi
    done
    
    # Wait for frontend
    print_status "Waiting for frontend..."
    timeout=60
    while ! curl -f http://localhost:4200 >/dev/null 2>&1; do
        sleep 2
        timeout=$((timeout - 2))
        if [ $timeout -le 0 ]; then
            print_error "Frontend failed to start within 60 seconds"
            exit 1
        fi
    done
    
    print_status "All services are ready!"
}

# Function to run database migrations
run_migrations() {
    print_status "Running database migrations..."
    
    # Generate Prisma client
    docker-compose -f docker-compose.vps.yml exec backend npx prisma generate
    
    # Run migrations
    docker-compose -f docker-compose.vps.yml exec backend npx prisma migrate deploy
    
    print_status "Database migrations completed."
}

# Function to create default admin user
create_default_user() {
    print_status "Creating default admin user..."
    
    # You can customize this default user
    DEFAULT_EMAIL="admin@company.com"
    DEFAULT_PASSWORD="admin123"
    
    print_status "Default admin credentials:"
    print_status "Email: $DEFAULT_EMAIL"
    print_status "Password: $DEFAULT_PASSWORD"
    print_warning "Please change these credentials after first login!"
    
    # Create user via API (optional - uncomment if needed)
    # curl -X POST http://localhost:5000/api/auth/register \
    #   -H "Content-Type: application/json" \
    #   -d "{\"email\":\"$DEFAULT_EMAIL\",\"password\":\"$DEFAULT_PASSWORD\",\"firstName\":\"Admin\",\"lastName\":\"User\",\"role\":\"ADMIN\"}" || true
}

# Function to display status
display_status() {
    print_status "Deployment completed successfully!"
    echo ""
    echo "=================================================="
    echo "🎉 Company Management System is now running!"
    echo "=================================================="
    echo ""
    echo "📍 Access URLs:"
    echo "   Frontend: http://$VPS_IP:4200"
    echo "   Backend API: http://$VPS_IP:5000"
    echo "   API Documentation: http://$VPS_IP:5000/api-docs"
    echo ""
    echo "📊 Service Status:"
    docker-compose -f docker-compose.vps.yml ps
    echo ""
    echo "🔧 Management Commands:"
    echo "   View logs: docker-compose -f docker-compose.vps.yml logs -f"
    echo "   Stop services: docker-compose -f docker-compose.vps.yml down"
    echo "   Restart services: docker-compose -f docker-compose.vps.yml restart"
    echo ""
    echo "⚠️  Important Notes:"
    echo "   - Change default admin credentials immediately"
    echo "   - Update JWT secrets in production"
    echo "   - Configure firewall rules for ports 4200, 5000"
    echo "   - Set up SSL certificates for production"
    echo ""
}

# Function to handle errors
handle_error() {
    print_error "Deployment failed!"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "1. Check Docker logs: docker-compose -f docker-compose.vps.yml logs"
    echo "2. Check system resources: docker system df"
    echo "3. Check port availability: netstat -tulpn | grep -E ':(4200|5000|5432)'"
    echo "4. Check firewall: sudo ufw status"
    echo ""
    echo "🔄 To retry deployment, run: ./deploy-vps.sh"
    exit 1
}

# Main deployment function
main() {
    # Set up error handling
    trap handle_error ERR
    
    echo "Starting deployment process..."
    echo "VPS IP: $VPS_IP"
    echo ""
    
    # Run deployment steps
    check_requirements
    create_backup
    stop_existing_containers
    setup_environment
    build_and_start
    wait_for_services
    run_migrations
    create_default_user
    display_status
    
    print_status "Deployment process completed!"
}

# Check if script is run as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Run main function
main "$@"