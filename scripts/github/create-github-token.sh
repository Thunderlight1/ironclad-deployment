#!/bin/bash
# Create GitHub Personal Access Token via CLI

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "${GREEN}========================================${NC}"
echo "${GREEN}GitHub Token Creation${NC}"
echo "${GREEN}========================================${NC}"

# Install GitHub CLI if not present
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh -y
fi

# Login to GitHub (interactive)
echo ""
echo "${YELLOW}Please login to GitHub (this will open a browser or prompt for code):${NC}"
gh auth login -h github.com -s repo,workflow,write:packages -w

# Get the token
TOKEN=$(gh auth token)

echo ""
echo "${GREEN}✅ Token created successfully!${NC}"
echo ""
echo "Token: ${TOKEN:0:20}...${TOKEN: -10}"
echo ""
echo "To store this token in OpenBao, run these commands:"
echo ""
echo "  docker exec openbao bao kv put secret/ironclad/github_token value=\"$TOKEN\""
echo "  docker exec openbao bao kv put secret/ironclad/github_username value=\"$(gh api user --jq '.login')\""
echo ""
read -p "Enter your GitHub repository URL (e.g., https://github.com/username/ironclad-deployment.git): " REPO_URL
echo "  docker exec openbao bao kv put secret/ironclad/github_repo value=\"$REPO_URL\""
echo ""
read -p "Enter your Git user name: " GIT_NAME
echo "  docker exec openbao bao kv put secret/ironclad/git_user_name value=\"$GIT_NAME\""
echo ""
read -p "Enter your Git email: " GIT_EMAIL
echo "  docker exec openbao bao kv put secret/ironclad/git_user_email value=\"$GIT_EMAIL\""
echo ""
echo "Then run: /opt/ironclad-stack/scripts/github/secure-push.sh"
