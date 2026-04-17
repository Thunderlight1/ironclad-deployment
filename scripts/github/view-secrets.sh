#!/bin/bash
# View stored secrets in OpenBao

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "${GREEN}========================================${NC}"
echo "${GREEN}Stored Secrets in OpenBao${NC}"
echo "${GREEN}========================================${NC}"

# Check if OpenBao is running
if ! docker ps | grep -q openbao; then
    echo "❌ OpenBao is not running"
    exit 1
fi

# Set OpenBao environment
export BAO_ADDR="https://localhost:8200"
export BAO_SKIP_VERIFY=true
export BAO_TOKEN=$(cat /opt/openbao/.root-token 2>/dev/null)

if [ -z "$BAO_TOKEN" ]; then
    echo "❌ OpenBao token not found"
    exit 1
fi

echo ""
echo "${BLUE}GitHub Secrets:${NC}"
echo "  github_username: $(docker exec openbao bao kv get -field=value secret/ironclad/github_username 2>/dev/null || echo 'not set')"
echo "  github_repo: $(docker exec openbao bao kv get -field=value secret/ironclad/github_repo 2>/dev/null || echo 'not set')"
echo "  github_token: $(docker exec openbao bao kv get -field=value secret/ironclad/github_token 2>/dev/null | sed 's/./*/g' || echo 'not set')"
echo "  git_user_name: $(docker exec openbao bao kv get -field=value secret/ironclad/git_user_name 2>/dev/null || echo 'not set')"
echo "  git_user_email: $(docker exec openbao bao kv get -field=value secret/ironclad/git_user_email 2>/dev/null || echo 'not set')"

echo ""
echo "${BLUE}Proxmox Secrets:${NC}"
echo "  proxmox_host: $(docker exec openbao bao kv get -field=value secret/ironclad/proxmox_host 2>/dev/null || echo 'not set')"
echo "  proxmox_user: $(docker exec openbao bao kv get -field=value secret/ironclad/proxmox_user 2>/dev/null || echo 'not set')"
echo "  proxmox_node: $(docker exec openbao bao kv get -field=value secret/ironclad/proxmox_node 2>/dev/null || echo 'not set')"
echo "  proxmox_token: $(docker exec openbao bao kv get -field=value secret/ironclad/proxmox_token 2>/dev/null | sed 's/./*/g' || echo 'not set')"

echo ""
echo "${YELLOW}To store new secrets, run:${NC}"
echo "  /opt/ironclad-stack/scripts/github/secure-push.sh"
echo "  /opt/ironclad-stack/scripts/github/store-proxmox-token.sh"
echo "========================================="
