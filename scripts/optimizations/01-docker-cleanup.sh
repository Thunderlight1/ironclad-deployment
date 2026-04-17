#!/bin/bash
# Docker cleanup automation

echo "🐳 Cleaning up Docker resources..."

docker container prune -f
docker network prune -f
docker image prune -a --filter "until=168h" -f
docker builder prune -f
docker volume prune -f

echo "✅ Cleanup complete!"
docker system df
