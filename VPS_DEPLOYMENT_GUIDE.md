# VPS Deployment Guide - Company Management System

This guide provides step-by-step instructions to deploy the Company Management System on your VPS server with IP `72.61.173.90`.

## 🚀 Quick Start

### 1. Upload Project Files

Upload the entire project to your VPS server:

```bash
# Connect to your VPS
ssh root@72.61.173.90

# Create project directory
mkdir -p /opt/company-management
cd /opt/company-management

# Upload files (use your preferred method)
# Option 1: Using scp from your local machine
scp -r * root@72.61.173.90:/opt/company-management/

# Option 2: Using git (if you have a git repository)
git clone <your-repository-url> .

# Option 3: Using wget to download archive
wget <your-archive-url>
tar -xzf <archive-file>
```

### 2. Make Deployment Script Executable

```bash
chmod +x deploy-vps.sh
```

### 3. Run the Deployment

```bash
# Run the automated deployment script
./deploy-vps.sh
```

The script will:
- ✅ Check system requirements
- ✅ Create backups (if existing data exists)
- ✅ Configure environment variables
- ✅ Build and start all services
- ✅ Run database migrations
- ✅ Verify deployment success

### 4. Access Your Application

Once deployment is complete, access your application at:

- **Frontend**: http://72.61.173.90:4200
- **Backend API**: http://72.61.173.90:5000
- **API Documentation**: http://72.61.173.90:5000/api-docs

## 📋 Manual Deployment Steps

If you prefer manual deployment or the automated script fails:

### Step 1: System Requirements Check

```bash
# Check Docker installation
docker --version
docker-compose --version

# Check available ports
netstat -tulpn | grep -E ':(4200|5000|5432)'

# Check memory (minimum 2GB recommended)
free -h
```

### Step 2: Environment Configuration

```bash
# Copy VPS environment files
cp backend/.env.vps backend/.env
cp frontend/.env.vps frontend/.env.local

# Optional: Edit environment files if needed
nano backend/.env
nano frontend/.env.local
```

### Step 3: Build and Start Services

```bash
# Build all services
docker-compose -f docker-compose.vps.yml build

# Start services in detached mode
docker-compose -f docker-compose.vps.yml up -d

# Check service status
docker-compose -f docker-compose.vps.yml ps

# View logs
docker-compose -f docker-compose.vps.yml logs -f
```

### Step 4: Database Setup

```bash
# Generate Prisma client
docker-compose -f docker-compose.vps.yml exec backend npx prisma generate

# Run migrations
docker-compose -f docker-compose.vps.yml exec backend npx prisma migrate deploy

# Verify database connection
docker-compose -f docker-compose.vps.yml exec backend npx prisma db ping
```

## 🔧 Configuration Options

### Environment Variables

Key environment variables you can customize:

**Backend (.env)**
```bash
# Security (CHANGE THESE!)
JWT_SECRET="your-secure-jwt-secret-min-32-chars"
JWT_REFRESH_SECRET="your-secure-refresh-secret-min-32-chars"

# Database (if using external database)
DATABASE_URL="postgresql://user:pass@host:5432/dbname"

# Email (optional)
SMTP_HOST="smtp.gmail.com"
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"
```

**Frontend (.env.local)**
```bash
# API URL (update if using different ports)
NEXT_PUBLIC_API_URL=http://72.61.173.90:5000
```

### Port Configuration

Default ports:
- **Frontend**: 4200 (mapped to container port 3000)
- **Backend**: 5000
- **Database**: 5432 (internal only)
- **Nginx**: 80 (alternative: 4201)

To change ports, edit `docker-compose.vps.yml`:
```yaml
ports:
  - "YOUR_PORT:3000"  # Frontend
  - "YOUR_PORT:5000"  # Backend
```

## 🔒 Security Configuration

### Firewall Setup

```bash
# Install UFW (if not installed)
apt install ufw

# Allow SSH
ufw allow 22/tcp

# Allow application ports
ufw allow 4200/tcp
ufw allow 5000/tcp
ufw allow 80/tcp

# Enable firewall
ufw enable

# Check status
ufw status
```

### Change Default Secrets

**IMPORTANT**: Change these secrets before production use:

1. Edit `backend/.env.vps`:
```bash
JWT_SECRET="your-super-secure-secret-key-minimum-32-characters"
JWT_REFRESH_SECRET="your-super-secure-refresh-key-minimum-32-characters"
```

2. Regenerate and restart:
```bash
docker-compose -f docker-compose.vps.yml down
docker-compose -f docker-compose.vps.yml up -d --build
```

## 📊 Service Management

### Check Service Status
```bash
# View all services
docker-compose -f docker-compose.vps.yml ps

# View logs
docker-compose -f docker-compose.vps.yml logs -f

# View specific service logs
docker-compose -f docker-compose.vps.yml logs backend
docker-compose -f docker-compose.vps.yml logs frontend
```

### Start/Stop/Restart Services
```bash
# Stop all services
docker-compose -f docker-compose.vps.yml down

# Start all services
docker-compose -f docker-compose.vps.yml up -d

# Restart specific service
docker-compose -f docker-compose.vps.yml restart backend

# Restart all services
docker-compose -f docker-compose.vps.yml restart
```

### Update Application
```bash
# Pull latest changes (if using git)
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.vps.yml down
docker-compose -f docker-compose.vps.yml build --no-cache
docker-compose -f docker-compose.vps.yml up -d
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Find process using port
netstat -tulpn | grep :4200
netstat -tulpn | grep :5000

# Kill process (if safe to do so)
kill -9 <PID>
```

#### 2. Database Connection Failed
```bash
# Check database logs
docker-compose -f docker-compose.vps.yml logs postgres

# Restart database
docker-compose -f docker-compose.vps.yml restart postgres

# Check database connection
docker-compose -f docker-compose.vps.yml exec backend npx prisma db ping
```

#### 3. Build Failures
```bash
# Clear Docker cache
docker system prune -a

# Rebuild with no cache
docker-compose -f docker-compose.vps.yml build --no-cache
```

#### 4. Memory Issues
```bash
# Check memory usage
docker stats

# Check system memory
free -h

# Increase Docker memory limits (edit docker-compose.vps.yml)
```

### Health Checks

```bash
# Backend health check
curl http://72.61.173.90:5000/health

# Frontend health check
curl http://72.61.173.90:4200

# Database health check
docker-compose -f docker-compose.vps.yml exec postgres pg_isready -U postgres
```

## 📈 Performance Optimization

### System Optimization
```bash
# Update system
apt update && apt upgrade -y

# Install htop for monitoring
apt install htop

# Monitor system resources
htop
```

### Docker Optimization
```bash
# Clean up unused containers and images
docker system prune -a

# Monitor container resources
docker stats

# View container logs with limits
docker-compose -f docker-compose.vps.yml logs --tail=100
```

## 🔍 Monitoring

### Application Monitoring
```bash
# View real-time logs
docker-compose -f docker-compose.vps.yml logs -f

# Monitor specific service
docker-compose -f docker-compose.vps.yml logs -f backend

# Check service health
docker-compose -f docker-compose.vps.yml ps
```

### System Monitoring
```bash
# System load
uptime

# Memory usage
free -h

# Disk usage
df -h

# Network connections
netstat -tulpn
```

## 🔄 Backup and Recovery

### Database Backup
```bash
# Create backup
docker-compose -f docker-compose.vps.yml exec postgres pg_dump -U postgres company_management > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker-compose -f docker-compose.vps.yml exec -T postgres psql -U postgres company_management < backup_file.sql
```

### File Backup
```bash
# Backup uploads
docker-compose -f docker-compose.vps.yml exec backend tar -czf /tmp/uploads_backup.tar.gz /app/uploads
docker cp company-management-backend:/tmp/uploads_backup.tar.gz ./
```

## 🆘 Getting Help

If you encounter issues:

1. **Check logs**: `docker-compose -f docker-compose.vps.yml logs`
2. **Check status**: `docker-compose -f docker-compose.vps.yml ps`
3. **Check resources**: `docker stats`
4. **Check ports**: `netstat -tulpn | grep -E ':(4200|5000)'`
5. **Restart services**: `docker-compose -f docker-compose.vps.yml restart`

For additional support, provide:
- Error messages from logs
- System specifications (RAM, CPU)
- Docker and Docker Compose versions
- Output of `docker-compose -f docker-compose.vps.yml ps`

## 📞 Contact Information

**Default Admin Credentials** (change immediately):
- Email: admin@company.com
- Password: admin123

**Support URLs**:
- Application: http://72.61.173.90:4200
- API Docs: http://72.61.173.90:5000/api-docs
- Health Check: http://72.61.173.90:5000/health

---

**🎉 Your Company Management System is now ready to use!**