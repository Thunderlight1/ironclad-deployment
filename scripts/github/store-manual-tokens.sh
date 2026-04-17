#!/bin/bash
# Manual helper to store tokens in OpenBao

echo "========================================="
echo "Manual Token Storage Helper"
echo "========================================="
echo ""

# Check OpenBao
if ! docker ps | grep -q openbao; then
    echo "❌ OpenBao not running. Start it first: docker start openbao"
    exit 1
fi

export BAO_ADDR="https://localhost:8200"
export BAO_SKIP_VERIFY=true
export BAO_TOKEN=$(cat /opt/openbao/.root-token 2>/dev/null)

echo "Enter your credentials:"
echo ""

read -p "GitHub Username: " GITHUB_USER
read -sp "GitHub Personal Access Token: " GITHUB_TOKEN
echo ""
read -p "GitHub Repo URL (e.g., https://github.com/user/ironclad-deployment.git): " GITHUB_REPO
read -p "Git User Name: " GIT_NAME
read -p "Git User Email: " GIT_EMAIL

echo ""
echo "Storing in OpenBao..."
docker exec openbao bao kv put secret/ironclad/github_token value="$GITHUB_TOKEN"
docker exec openbao bao kv put secret/ironclad/github_username value="$GITHUB_USER"
docker exec openbao bao kv put secret/ironclad/github_repo value="$GITHUB_REPO"
docker exec openbao bao kv put secret/ironclad/git_user_name value="$GIT_NAME"
docker exec openbao bao kv put secret/ironclad/git_user_email value="$GIT_EMAIL"

echo ""
echo "✅ All credentials stored in OpenBao!"
echo ""
echo "Run secure push: /opt/ironclad-stack/scripts/github/secure-push.sh"
