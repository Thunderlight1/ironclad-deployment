#!/bin/bash
# Secure GitHub Push with OpenBao key storage

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "${GREEN}========================================${NC}"
echo "${GREEN}Secure GitHub Push with OpenBao${NC}"
echo "${GREEN}========================================${NC}"

# Check if OpenBao is running
if ! docker ps | grep -q openbao; then
    echo "${RED}❌ OpenBao is not running${NC}"
    echo "Starting OpenBao..."
    docker start openbao 2>/dev/null || echo "OpenBao not found. Please start it first."
    exit 1
fi

# Set OpenBao environment
export BAO_ADDR="https://localhost:8200"
export BAO_SKIP_VERIFY=true
export BAO_TOKEN=$(cat /opt/openbao/.root-token 2>/dev/null)

if [ -z "$BAO_TOKEN" ]; then
    echo "${RED}❌ OpenBao token not found${NC}"
    exit 1
fi

# Get secrets from OpenBao
GITHUB_TOKEN=$(docker exec openbao bao kv get -field=value secret/ironclad/github_token 2>/dev/null || echo "")
GITHUB_USERNAME=$(docker exec openbao bao kv get -field=value secret/ironclad/github_username 2>/dev/null || echo "")
GITHUB_REPO=$(docker exec openbao bao kv get -field=value secret/ironclad/github_repo 2>/dev/null || echo "")
GIT_USER_NAME=$(docker exec openbao bao kv get -field=value secret/ironclad/git_user_name 2>/dev/null || echo "")
GIT_USER_EMAIL=$(docker exec openbao bao kv get -field=value secret/ironclad/git_user_email 2>/dev/null || echo "")

if [ -z "$GITHUB_TOKEN" ]; then
    echo "${RED}❌ GitHub credentials not found in OpenBao${NC}"
    echo "Please run: /opt/ironclad-stack/scripts/github/create-github-token.sh"
    exit 1
fi

echo "${GREEN}✅ GitHub credentials loaded from OpenBao${NC}"

# Configure git
echo "⚙️ Configuring git..."
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global credential.helper store

# Setup GitHub authentication
echo "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

# Navigate to stack directory
cd /opt/ironclad-stack

# Initialize git if not exists
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    git remote add origin $GITHUB_REPO
fi

# Create .gitignore if not exists
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore..."
    echo "credentials.json" > .gitignore
    echo ".env" >> .gitignore
    echo "*.log" >> .gitignore
    echo ".openbao-token" >> .gitignore
    echo "backups/" >> .gitignore
fi

# Add all files
echo "📦 Staging files..."
git add .
git add -f scripts/ optimizations/ docker-compose/ terraform/ ansible/ meal-plans/ 2>/dev/null || true

# Commit changes
echo "💾 Committing changes..."
git commit -m "Automated deployment - $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || echo "No changes to commit"

# Push to GitHub
echo "🚀 Pushing to GitHub..."
git push -u origin main --force 2>/dev/null || git push -u origin master --force 2>/dev/null

echo ""
echo "${GREEN}✅ Successfully pushed to GitHub!${NC}"
echo "${GREEN}📁 Repository: $GITHUB_REPO${NC}"
echo "========================================="
