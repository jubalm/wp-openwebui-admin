#!/bin/bash

# Cleanup script for WordPress and OpenWebUI Integration PoC
# This script stops and removes all containers and volumes

set -e

echo "🧹 Cleaning up WordPress and OpenWebUI Integration PoC..."

# Set Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    DOCKER_COMPOSE="docker compose"
fi

# Stop and remove containers
echo "🛑 Stopping containers..."
$DOCKER_COMPOSE down --remove-orphans

# Remove volumes (optional - uncomment if you want to remove all data)
echo "❓ Remove all data volumes? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🗑️ Removing volumes..."
    $DOCKER_COMPOSE down --volumes
    docker volume prune -f
    echo "✅ All volumes removed"
else
    echo "💾 Volumes preserved"
fi

# Remove unused images (optional)
echo "❓ Remove unused Docker images? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🗑️ Removing unused images..."
    docker image prune -f
    echo "✅ Unused images removed"
fi

# Clean up any temporary files
echo "🧹 Cleaning temporary files..."
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "*.log" -delete 2>/dev/null || true

echo ""
echo "🎉 Cleanup completed!"
echo ""
echo "📋 What was cleaned:"
echo "   ✅ Docker containers stopped and removed"
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "   ✅ Docker volumes removed"
    echo "   ✅ All data deleted"
else
    echo "   💾 Docker volumes preserved"
    echo "   💾 Data preserved"
fi
echo ""
echo "🔄 To restart the PoC:"
echo "   ./scripts/setup.sh"