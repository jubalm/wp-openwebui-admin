#!/bin/bash
set -euo pipefail

# WordPress Custom Image Build Script
# This script builds the custom WordPress Docker image with pre-installed plugins

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

IMAGE_NAME="wp-openwebui-admin/wordpress-custom"
IMAGE_TAG="${1:-latest}"
DOCKERFILE_PATH="$PROJECT_ROOT/docker/wordpress"

echo "Building custom WordPress image..."
echo "Image: $IMAGE_NAME:$IMAGE_TAG"
echo "Dockerfile path: $DOCKERFILE_PATH"

# Build the Docker image
cd "$PROJECT_ROOT"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" -f "$DOCKERFILE_PATH/Dockerfile" "$DOCKERFILE_PATH"

echo "✅ Custom WordPress image built successfully!"
echo "Image: $IMAGE_NAME:$IMAGE_TAG"
echo ""
echo "To use the image, update your docker-compose.yml to reference:"
echo "  image: $IMAGE_NAME:$IMAGE_TAG"
echo ""
echo "Or rebuild your stack with:"
echo "  docker-compose up --build"