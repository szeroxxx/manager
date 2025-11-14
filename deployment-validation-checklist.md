# VPS Deployment Validation Checklist

## Pre-Deployment Validation

### 1. System Requirements Check
- [ ] VPS has Docker and Docker Compose installed
- [ ] VPS has at least 2GB RAM available
- [ ] VPS has at least 10GB disk space available
- [ ] Port 4200 is available for frontend
- [ ] Port 5000 is available for backend
- [ ] Port 5432 is available for PostgreSQL

### 2. File Structure Validation
- [ ] All project files are present in the deployment directory
- [ ] docker-compose.vps.yml exists and is properly configured
- [ ] Environment files (.env.vps) exist for both frontend and backend
- [ ] Nginx configuration file (nginx-vps.conf) is present
- [ ] Deployment scripts are executable

### 3. Configuration Validation
- [ ] Frontend environment variables point to correct backend IP
- [ ] Backend CORS configuration allows frontend IP
- [ ] Database connection string is properly configured
- [ ] JWT secrets are properly set
- [ ] Nginx configuration is set for IP-based access

### 4. Docker Configuration Test
- [ ] All Docker images build successfully
- [ ] Container dependencies are properly configured
- [ ] Health checks are working
- [ ] Volume mounts are correctly set

## Deployment Process Validation

### 5. VPS Setup Script Execution
- [ ] System packages are updated
- [ ] Docker and Docker Compose are installed
- [ ] Firewall rules are configured
- [ ] Required ports are open

### 6. Application Deployment
- [ ] Docker containers start without errors
- [ ] Database initializes properly
- [ ] Backend API is accessible
- [ ] Frontend is accessible
- [ ] All services pass health checks

### 7. Integration Testing
- [ ] Frontend can communicate with backend
- [ ] Database connections are working
- [ ] Authentication system is functional
- [ ] API endpoints respond correctly
- [ ] Static assets are served properly

## Post-Deployment Validation

### 8. Performance Testing
- [ ] Application loads within acceptable time
- [ ] API response times are reasonable
- [ ] Database queries execute efficiently
- [ ] No memory leaks detected

### 9. Security Validation
- [ ] JWT tokens are properly validated
- [ ] CORS is configured correctly
- [ ] Rate limiting is working
- [ ] No sensitive data is exposed
- [ ] Database is not directly accessible from outside

### 10. Monitoring and Logging
- [ ] Application logs are accessible
- [ ] Error logging is working
- [ ] Health check endpoints respond
- [ ] Container restart policies are configured

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :4200
sudo lsof -i :5000

# Kill the process if needed
sudo kill -9 <PID>
```

#### 2. Docker Permission Issues
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

#### 3. Database Connection Issues
```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Test database connection
docker exec -it companymanager-postgres-1 psql -U postgres -d companymanager
```

#### 4. Memory Issues
```bash
# Check available memory
free -h

# Check container memory usage
docker stats
```

#### 5. Network Connectivity Issues
```bash
# Test network connectivity
curl -I http://72.61.173.90:4200
curl -I http://72.61.173.90:5000/health

# Check container networking
docker network ls
docker network inspect <network_name>
```

## Emergency Rollback Procedure

1. **Stop all containers**
```bash
docker-compose -f docker-compose.vps.yml down
```

2. **Backup current state**
```bash
docker-compose -f docker-compose.vps.yml logs > deployment-logs-$(date +%Y%m%d-%H%M%S).txt
```

3. **Restore from backup** (if available)
```bash
# Restore database backup
docker exec -i companymanager-postgres-1 psql -U postgres companymanager < backup.sql
```

4. **Restart services**
```bash
docker-compose -f docker-compose.vps.yml up -d
```

## Success Criteria

✅ **Deployment is successful when:**
- Frontend is accessible at http://72.61.173.90:4200
- Backend API responds at http://72.61.173.90:5000/health
- Database is accessible and initialized
- All containers are running without errors
- Authentication system works end-to-end
- No critical errors in logs
- Application performs within acceptable parameters

## Contact Information

- **VPS IP**: 72.61.173.90:4200
- **Backend API**: http://72.61.173.90:5000
- **Frontend URL**: http://72.61.173.90:4200
- **Support**: Check deployment logs and troubleshooting guide first