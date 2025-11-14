#!/bin/bash

# Company Management System - GitHub Deployment Script
# This script prepares and pushes your code to GitHub for VPS deployment

set -e

echo "=========================================="
echo "🚀 Company Management System - GitHub Deployment"
echo "=========================================="
echo "Preparing code for GitHub deployment..."
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

# Check if git is available
check_git() {
    if command -v git >/dev/null 2>&1; then
        print_status "Git is available"
        return 0
    else
        print_error "Git is not available. Please install git first."
        return 1
    fi
}

# Check current git status
check_git_status() {
    if [ -d ".git" ]; then
        print_status "Git repository detected"
        return 0
    else
        print_warning "No git repository found. Initializing new repository..."
        git init
        return 0
    fi
}

# Check for uncommitted changes
check_uncommitted_changes() {
    if [[ -n $(git status -s) ]]; then
        print_warning "Uncommitted changes detected"
        echo "Files that will be committed:"
        git status -s
        return 0
    else
        print_status "No uncommitted changes"
        return 0
    fi
}

# Create .gitignore if it doesn't exist
create_gitignore() {
    if [ ! -f ".gitignore" ]; then
        print_status "Creating .gitignore file..."
        cat > .gitignore << 'EOF'
# Dependencies
node_modules/
*/node_modules/

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build outputs
dist/
build/
.next/
*.tsbuildinfo

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# Database
*.db
*.sqlite

# Uploads
uploads/
!uploads/.gitkeep

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Docker
.docker/

# Temporary files
tmp/
temp/
EOF
        print_status ".gitignore file created"
    else
        print_status ".gitignore file already exists"
    fi
}

# Add all files to git
add_files_to_git() {
    print_status "Adding files to git..."
    git add .
    print_status "Files added to git staging area"
}

# Commit changes
commit_changes() {
    local commit_message="Update: Fix Docker build issues and VPS deployment configuration

- Fixed backend Dockerfile to include TypeScript build dependencies
- Added Prisma client generation in Docker build process
- Updated Next.js configuration for standalone Docker deployment
- Configured docker-compose.yml for VPS deployment at 72.61.173.90:4200
- Added health checks and restart policies for all services
- Updated CORS configuration for VPS IP access
- Added comprehensive deployment documentation"

    print_status "Committing changes..."
    git commit -m "$commit_message" || print_warning "No changes to commit"
}

# Check remote repository
check_remote() {
    if git remote get-url origin >/dev/null 2>&1; then
        local remote_url=$(git remote get-url origin)
        print_status "Remote repository found: $remote_url"
        return 0
    else
        print_warning "No remote repository configured"
        return 1
    fi
}

# Set up remote repository
setup_remote() {
    echo "Please enter your GitHub repository URL (e.g., https://github.com/username/repo.git):"
    read -r repo_url
    
    if [[ "$repo_url" =~ ^https://github\.com/.*\.git$ ]] || [[ "$repo_url" =~ ^git@github\.com:.*\.git$ ]]; then
        print_status "Setting up remote repository..."
        git remote add origin "$repo_url" || git remote set-url origin "$repo_url"
        print_status "Remote repository configured: $repo_url"
        return 0
    else
        print_error "Invalid GitHub repository URL format"
        return 1
    fi
}

# Push to GitHub
push_to_github() {
    print_status "Pushing to GitHub..."
    
    # Try to push, if it fails, set upstream and try again
    if git push origin main 2>/dev/null; then
        print_status "Successfully pushed to main branch"
    elif git push origin master 2>/dev/null; then
        print_status "Successfully pushed to master branch"
    else
        print_status "Setting upstream branch and pushing..."
        git push -u origin main 2>/dev/null || git push -u origin master
        print_status "Successfully pushed to GitHub"
    fi
}

# Display final instructions
show_final_instructions() {
    echo "=========================================="
    print_status "🎉 GitHub deployment preparation complete!"
    echo "=========================================="
    echo ""
    echo "Next steps for VPS deployment:"
    echo "1. Go to your Hostinger VPS Docker Manager"
    echo "2. Use this URL in the Docker Compose field:"
    echo "   https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/docker-compose.yml"
    echo "3. Project name: company-management-system"
    echo "4. Click 'Deploy'"
    echo ""
    echo "Your application will be available at:"
    echo "   Frontend: http://72.61.173.90:4200"
    echo "   Backend API: http://72.61.173.90:5000"
    echo ""
    echo "⚠️  IMPORTANT: Update security settings after deployment:"
    echo "   - Change JWT secrets in docker-compose.yml"
    echo "   - Change database password"
    echo "   - Update environment variables"
    echo "=========================================="
}

# Main function
main() {
    echo "Starting GitHub deployment preparation..."
    echo ""
    
    # Run checks and setup
    check_git
    check_git_status
    check_uncommitted_changes
    create_gitignore
    
    echo ""
    echo "Current git status:"
    git status
    echo ""
    
    read -p "Do you want to continue with adding and committing files? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        add_files_to_git
        commit_changes
        
        if check_remote; then
            read -p "Do you want to push to the existing remote repository? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                push_to_github
            fi
        else
            read -p "Do you want to set up a GitHub remote repository? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if setup_remote; then
                    push_to_github
                fi
            fi
        fi
    fi
    
    show_final_instructions
}

# Run the main function
main "$@"