# Company Management System - Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying the Company Management System using Docker containers. The system consists of three main components:

- **Frontend**: Next.js application
- **Backend**: Node.js/Express API
- **Database**: PostgreSQL

## Prerequisites

### System Requirements

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Memory**: Minimum 4GB RAM (8GB recommended)
- **Storage**: Minimum 10GB free space
- **CPU**: 2 cores minimum (4 cores recommended)

### Environment Setup

1. **Clone or copy the project files** to your deployment server
2. **Configure environment variables** (see Environment Configuration section)
3. **Set up SSL certificates** (for production deployment)

## Environment Configuration

### Backend Environment Variables

Create a `.env` file in the `backend` directory:

```bash
# Database Configuration
DATABASE_URL="postgresql://username:password@localhost:5432/company_management?schema=public"

# JWT Configuration
JWT_SECRET="your-super-secret-jwt-key-min-32-characters"
JWT_REFRESH_SECRET="your-super-secret-refresh-jwt-key-min-32-characters"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Server Configuration
NODE_ENV="production"
PORT=5000
API_URL="https://your-domain.com"
FRONTEND_URL="https://your-domain.com"

# Email Configuration (Optional)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT=587
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"

# Security Configuration
BCRYPT_ROUNDS=12
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# CORS Configuration
CORS_ORIGIN="https://your-domain.com"
CORS_CREDENTIALS=true
```

### Frontend Environment Variables

Create a `.env.local` file in the `frontend` directory:

```bash
# Backend API Configuration
NEXT_PUBLIC_API_URL=https://your-domain.com
NEXT_PUBLIC_API_VERSION=/api

# Application Configuration
NEXT_PUBLIC_APP_NAME="Company Management System"
NEXT_PUBLIC_APP_DESCRIPTION="Comprehensive company management system"

# Authentication Configuration
NEXT_PUBLIC_JWT_TOKEN_KEY=auth-token
NEXT_PUBLIC_REFRESH_TOKEN_KEY=refresh-token

# Environment
NODE_ENV=production
```

## Deployment Steps

### 1. Development Deployment

For local development with hot reloading:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 2. Production Deployment

For production deployment with SSL and optimized settings:

```bash
# Build and start production services
docker-compose -f docker-compose.yml up -d --build

# Scale backend instances (optional)
docker-compose up -d --scale backend=3

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 3. Database Setup

The PostgreSQL database will be automatically initialized. To run migrations:

```bash
# Run Prisma migrations
docker-compose exec backend npx prisma migrate deploy

# Generate Prisma client
docker-compose exec backend npx prisma generate

# Access database directly
docker-compose exec postgres psql -U postgres -d company_management
```

## SSL Certificate Setup

### Using Let's Encrypt (Recommended)

1. **Install Certbot**:
```bash
sudo apt-get update
sudo apt-get install certbot
```

2. **Generate Certificate**:
```bash
sudo certbot certonly --standalone -d your-domain.com
```

3. **Copy Certificates**:
```bash
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ./ssl/key.pem
```

### Using Self-Signed Certificates (Development)

```bash
# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes
```

## Monitoring and Maintenance

### Health Checks

All services include health checks. Monitor them with:

```bash
# Check service health
docker-compose ps

# View health check logs
docker-compose logs --tail=50 backend
docker-compose logs --tail=50 frontend
docker-compose logs --tail=50 postgres
```

### Backup Procedures

#### Database Backup

```bash
# Create backup
docker-compose exec postgres pg_dump -U postgres company_management > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker-compose exec -T postgres psql -U postgres company_management < backup_file.sql
```

#### File System Backup

```bash
# Backup uploads
docker-compose exec backend tar -czf /tmp/uploads_backup.tar.gz /app/uploads
docker cp company-management-backend:/tmp/uploads_backup.tar.gz ./
```

### Log Management

```bash
# View real-time logs
docker-compose logs -f service_name

# Rotate logs
docker-compose exec backend logrotate /etc/logrotate.conf

# Export logs
docker-compose logs backend > backend_logs.txt
```

## Performance Optimization

### Database Optimization

1. **Connection Pooling**: Configured in Prisma
2. **Indexing**: Ensure proper indexes on frequently queried columns
3. **Query Optimization**: Use EXPLAIN ANALYZE for slow queries

### Backend Optimization

1. **Rate Limiting**: Configured via middleware
2. **Caching**: Implement Redis caching for frequently accessed data
3. **Compression**: Enabled via compression middleware

### Frontend Optimization

1. **CDN**: Use CDN for static assets
2. **Image Optimization**: Use Next.js Image component
3. **Bundle Splitting**: Automatic with Next.js

## Security Considerations

### Network Security

- All services run in isolated Docker networks
- Database is not exposed to external networks
- Nginx acts as reverse proxy with rate limiting

### Application Security

- JWT tokens with proper expiration
- Password hashing with bcrypt
- Input validation and sanitization
- CORS configuration
- Helmet.js security headers

### Container Security

- Non-root users in containers
- Minimal base images (Alpine)
- Regular security updates
- Secret management via environment variables

## Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check database connectivity
docker-compose exec backend npx prisma db ping

# Reset database if needed
docker-compose exec backend npx prisma migrate reset
```

#### Port Conflicts
```bash
# Check port usage
sudo netstat -tulpn | grep :3000
sudo netstat -tulpn | grep :5000
sudo netstat -tulpn | grep :5432
```

#### Memory Issues
```bash
# Check memory usage
docker stats

# Increase Docker memory limits in docker-compose.yml
```

### Performance Issues

#### Slow Queries
```bash
# Enable query logging
docker-compose exec backend npx prisma generate --data-proxy
```

#### High CPU Usage
```bash
# Monitor CPU usage
docker-compose exec backend top

# Check for infinite loops or heavy computations
```

## Scaling

### Horizontal Scaling

```bash
# Scale backend instances
docker-compose up -d --scale backend=3

# Scale frontend instances (if using custom setup)
docker-compose up -d --scale frontend=2
```

### Vertical Scaling

Increase container resources in `docker-compose.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
```

## Monitoring Setup

### Application Monitoring

Consider integrating:
- **Sentry** for error tracking
- **Prometheus** for metrics
- **Grafana** for visualization
- **ELK Stack** for log aggregation

### Health Monitoring

Set up external monitoring for:
- Application uptime
- Response time
- Error rates
- Database connectivity

## Support and Maintenance

### Regular Maintenance Tasks

1. **Update dependencies** monthly
2. **Review logs** weekly
3. **Backup data** daily
4. **Monitor performance** continuously
5. **Update SSL certificates** as needed

### Getting Help

For issues and support:
1. Check application logs
2. Review Docker container status
3. Consult this deployment guide
4. Check system resources
5. Review network connectivity

This deployment guide ensures your Company Management System runs reliably and securely in production.