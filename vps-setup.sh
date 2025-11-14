#!/bin/bash

# Quick VPS Setup Script for Company Management System
# Run this on your VPS server

set -e

echo "🏗️  VPS Quick Setup for Company Management System"
echo "================================================="
echo ""

# Configuration
PROJECT_DIR="/opt/company-management"
VPS_IP="72.61.173.90"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root (use sudo)"
    exit 1
fi

# Update system
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install required packages
print_status "Installing required packages..."
apt install -y \
    docker.io \
    docker-compose \
    curl \
    wget \
    git \
    unzip \
    htop \
    ufw

# Enable and start Docker
print_status "Configuring Docker..."
systemctl enable docker
systemctl start docker

# Add current user to docker group (if not root)
if [ "$USER" != "root" ]; then
    usermod -aG docker $USER
fi

# Create project directory
print_status "Creating project directory..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Download project files (you'll need to upload these manually or provide download URL)
print_status "Project files need to be uploaded to: $PROJECT_DIR"
print_warning "Please upload the project files to $PROJECT_DIR and then run the deployment script"

# Create a simple upload helper script
cat > upload-helper.sh << 'EOF'
#!/bin/bash
# Helper script for uploading project files

echo "📁 Project Upload Helper"
echo "========================="
echo ""
echo "Please upload the following files to: $PROJECT_DIR"
echo ""
echo "Required files:"
echo "  - backend/ (entire directory)"
echo "  - frontend/ (entire directory)"
echo "  - docker-compose.vps.yml"
echo "  - nginx-vps.conf"
echo "  - deploy-vps.sh"
echo "  - VPS_DEPLOYMENT_GUIDE.md"
echo ""
echo "Upload methods:"
echo "  1. Using scp from local machine:"
echo "     scp -r /path/to/project/files root@72.61.173.90:/opt/company-management/"
echo ""
echo "  2. Using FileZilla or similar SFTP client"
echo ""
echo "  3. Using wget if files are hosted online:"
echo "     wget <url-to-project-archive>"
echo "     unzip <archive-file>"
echo ""
EOF

chmod +x upload-helper.sh

# Configure firewall
print_status "Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 4200/tcp  # Frontend
ufw allow 5000/tcp  # Backend API
ufw allow 80/tcp    # HTTP (nginx)
ufw allow 443/tcp   # HTTPS (future)
echo "y" | ufw enable

# Create systemd service for auto-start
cat > /etc/systemd/system/company-management.service << EOF
[Unit]
Description=Company Management System
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/docker-compose -f docker-compose.vps.yml up -d
ExecStop=/usr/bin/docker-compose -f docker-compose.vps.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable company-management.service

# Create deployment completion script
cat > complete-setup.sh << 'EOF'
#!/bin/bash
# Run this after uploading project files

cd /opt/company-management

# Make deployment script executable
chmod +x deploy-vps.sh

# Run deployment
./deploy-vps.sh

echo ""
echo "🎉 Setup completed! Your application should be accessible at:"
echo "   Frontend: http://72.61.173.90:4200"
echo "   Backend API: http://72.61.173.90:5000"
echo "   API Documentation: http://72.61.173.90:5000/api-docs"
echo ""
EOF

chmod +x complete-setup.sh

# Create status check script
cat > check-status.sh << 'EOF'
#!/bin/bash
# Quick status check script

echo "🔍 Company Management System Status Check"
echo "=========================================="
echo ""

# Check if Docker is running
if systemctl is-active --quiet docker; then
    echo "✅ Docker is running"
else
    echo "❌ Docker is not running"
fi

# Check firewall status
if systemctl is-active --quiet ufw; then
    echo "✅ UFW firewall is active"
    echo "Open ports:"
    ufw status | grep -E "(4200|5000|80|22)"
else
    echo "❌ UFW firewall is not active"
fi

# Check disk space
echo ""
echo "💾 Disk Space:"
df -h / | tail -1

# Check memory
echo ""
echo "🧠 Memory Usage:"
free -h | grep -E "(Mem|Swap)"

# Check if project directory exists
if [ -d "/opt/company-management" ]; then
    echo ""
    echo "📁 Project directory exists: /opt/company-management"
    ls -la /opt/company-management/ 2>/dev/null | head -10
else
    echo ""
    echo "❌ Project directory not found"
fi

echo ""
echo "📝 Next steps:"
echo "1. Upload project files to /opt/company-management"
echo "2. Run: cd /opt/company-management && ./complete-setup.sh"
echo ""
EOF

chmod +x check-status.sh

# Final instructions
echo ""
echo "✅ VPS preparation completed!"
echo ""
echo "📋 Next Steps:"
echo "1. Upload your project files to: $PROJECT_DIR"
echo "2. Run: cd $PROJECT_DIR && ./complete-setup.sh"
echo ""
echo "📁 Available helper scripts:"
echo "  - ./upload-helper.sh     # Upload instructions"
echo "  - ./check-status.sh      # System status check"
echo "  - ./complete-setup.sh    # Final deployment"
echo ""
echo "🔧 Management commands:"
echo "  - View logs: cd $PROJECT_DIR && docker-compose -f docker-compose.vps.yml logs -f"
echo "  - Stop services: cd $PROJECT_DIR && docker-compose -f docker-compose.vps.yml down"
echo "  - Restart services: cd $PROJECT_DIR && docker-compose -f docker-compose.vps.yml restart"
echo ""
echo "🌐 Your VPS IP: $VPS_IP"
echo ""
echo "⚠️  IMPORTANT: Make sure to upload all project files before running the deployment!"