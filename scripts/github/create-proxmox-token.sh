#!/bin/bash
# Create Proxmox API Token via CLI

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "${GREEN}========================================${NC}"
echo "${GREEN}Proxmox API Token Creation${NC}"
echo "${GREEN}========================================${NC}"

# Check if running on Proxmox node
if ! command -v pveum &> /dev/null; then
    echo "${RED}Not running on a Proxmox node${NC}"
    echo "Please run this script on your Proxmox host, or manually create the token."
    echo ""
    echo "Manual creation steps:"
    echo "1. SSH to your Proxmox host"
    echo "2. Run: pveum role add IroncladProv -privs \"VM.Allocate VM.Clone VM.Config.CPU VM.Config.Memory VM.Config.Disk VM.PowerMgmt Datastore.AllocateSpace\""
    echo "3. Run: pveum user add ironclad-prov@pve --comment \"Ironclad Automation\""
    echo "4. Run: pveum user token add ironclad-prov@pve ironclad-token --privsep 0"
    echo "5. Copy the token (format: USER@REALM!TOKENID=SECRET)"
    exit 1
fi

echo "${YELLOW}Creating Proxmox role for automation...${NC}"
pveum role add IroncladProv -privs "VM.Allocate VM.Clone VM.Config.CPU VM.Config.Memory VM.Config.Disk VM.Config.Network VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"

echo "${YELLOW}Creating automation user...${NC}"
pveum user add ironclad-prov@pve --comment "Ironclad Deployment Automation" 2>/dev/null || echo "User already exists"

echo "${YELLOW}Generating API token...${NC}"
TOKEN_OUTPUT=$(pveum user token add ironclad-prov@pve ironclad-token --privsep 0 2>/dev/null)

# Extract token
TOKEN_ID=$(echo "$TOKEN_OUTPUT" | grep -oP 'full token ID: \K[^\s]+' | head -1)
TOKEN_SECRET=$(echo "$TOKEN_OUTPUT" | grep -oP 'secret: \K[^\s]+' | head -1)

if [ -n "$TOKEN_ID" ] && [ -n "$TOKEN_SECRET" ]; then
    FULL_TOKEN="${TOKEN_ID}=${TOKEN_SECRET}"
    echo ""
    echo "${GREEN}✅ Token created successfully!${NC}"
    echo ""
    echo "Token ID: $TOKEN_ID"
    echo "Token Secret: $TOKEN_SECRET"
    echo ""
    echo "Full token: ${FULL_TOKEN:0:30}... (hidden)"
    echo ""
    
    # Set permissions
    echo "${YELLOW}Setting ACL permissions...${NC}"
    pveum aclmod / -user ironclad-prov@pve -role IroncladProv
    
    # Get host info
    PROXMOX_HOST=$(hostname -I | awk '{print $1}')
    PROXMOX_NODE=$(hostname)
    
    echo ""
    echo "Proxmox Host: $PROXMOX_HOST"
    echo "Proxmox Node: $PROXMOX_NODE"
    echo ""
    echo "To store this token in OpenBao, run:"
    echo "  /opt/ironclad-stack/scripts/github/store-proxmox-token.sh"
    echo ""
    echo "Or manually store with:"
    echo "  docker exec openbao bao kv put secret/ironclad/proxmox_token value=\"$FULL_TOKEN\""
    echo "  docker exec openbao bao kv put secret/ironclad/proxmox_host value=\"$PROXMOX_HOST\""
    echo "  docker exec openbao bao kv put secret/ironclad/proxmox_node value=\"$PROXMOX_NODE\""
    echo "  docker exec openbao bao kv put secret/ironclad/proxmox_user value=\"ironclad-prov@pve\""
else
    echo "${RED}Failed to create token${NC}"
    echo "$TOKEN_OUTPUT"
fi
