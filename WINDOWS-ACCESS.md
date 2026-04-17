# Ironclad Stack - Windows Access Guide

## Network Configuration

| Component | IP Address | Purpose |
|-----------|------------|---------|
| **Windows Client** | 10.10.10.2 | Your browsing machine |
| **Terraform/Ansible Server** | 10.10.10.6 | OpenBao, scripts, automation |
| **Docker Host** | 10.10.10.9 | All containers (Portainer, Mealie, etc.) |

## Access URLs (from Windows at 10.10.10.2)

### OpenBao (Secrets Management)
```
URL: http://10.10.10.6:8200
Token: root
```

### Docker Host Services (10.10.10.9)

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Portainer** | http://10.10.10.9:9000 | Create first user |
| **Mealie** | http://10.10.10.9:9925 | admin@ironclad.local / IroncladRecipe2024! |
| **Grafana** | http://10.10.10.9:3002 | admin / ironclad123 |
| **Homarr** | http://10.10.10.9:7575 | No auth (setup first user) |
| **JobSync** | http://10.10.10.9:3000 | Create first user |
| **Wekan** | http://10.10.10.9:8080 | Create first user |
| **n8n** | http://10.10.10.9:5678 | Create first user |
| **Prometheus** | http://10.10.10.9:9090 | No auth |
| **Immich** | http://10.10.10.9:2283 | Create first user |
| **Traefik** | http://10.10.10.9:8080 | No auth |

## SSH Access
```bash
# From MobaXterm or any SSH client
ssh cesar@10.10.10.6

# Or directly to Docker host
ssh cesar@10.10.10.9
```

## Quick Fish Commands (on Terraform Server)
```fish
bao-status              # Check OpenBao health
bao-secrets             # List all stored secrets
bao-get <key>           # Get a secret value
ironclad-status         # Full stack status
```
