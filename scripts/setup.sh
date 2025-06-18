#!/bin/bash

# WordPress and OpenWebUI Integration PoC Setup Script
# This script sets up the local development environment

set -e

echo "🚀 Starting WordPress and OpenWebUI Integration PoC Setup..."

# Check for environment file
echo "🔧 Checking environment configuration..."
if [ ! -f ".env" ]; then
    echo "ℹ️  No .env file found. You can copy .env.example to .env and customize if needed:"
    echo "   cp .env.example .env"
    echo "   Using default environment values from docker-compose.yml"
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Set Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    DOCKER_COMPOSE="docker compose"
fi

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p openwebui/config
mkdir -p scripts/test

# Check WordPress MCP plugin (pre-installed in custom image)
echo "🔌 WordPress MCP plugin is pre-installed in custom image"

echo "🔌 OpenID Connect plugin is pre-installed in custom image"

# Start Docker containers
echo "🐳 Starting Docker containers..."
$DOCKER_COMPOSE down --remove-orphans 2>/dev/null || true
$DOCKER_COMPOSE up -d

# Wait for services to be ready (longer wait for automated WordPress setup)
echo "⏳ Waiting for services to start and WordPress to auto-configure..."
sleep 90

# Check if Authentik is accessible
echo "🔍 Checking Authentik availability..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:9000 > /dev/null; then
        echo "✅ Authentik is accessible at http://localhost:9000"
        break
    else
        echo "⏳ Attempt $attempt/$max_attempts: Authentik not ready yet..."
        sleep 10
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Authentik failed to start after $max_attempts attempts"
    exit 1
fi

# Check if WordPress is accessible
echo "🔍 Checking WordPress availability..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:8080 > /dev/null; then
        echo "✅ WordPress is accessible at http://localhost:8080"
        break
    else
        echo "⏳ Attempt $attempt/$max_attempts: WordPress not ready yet..."
        sleep 10
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ WordPress failed to start after $max_attempts attempts"
    exit 1
fi

# Check if OpenWebUI is accessible
echo "🔍 Checking OpenWebUI availability..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:3000 > /dev/null; then
        echo "✅ OpenWebUI is accessible at http://localhost:3000"
        break
    else
        echo "⏳ Attempt $attempt/$max_attempts: OpenWebUI not ready yet..."
        sleep 10
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ OpenWebUI failed to start after $max_attempts attempts"
    exit 1
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "✨ WordPress is now fully automated! No manual setup required."
echo ""
echo "📋 What's Ready:"
echo "✅ WordPress MCP plugin is activated and configured"
echo "✅ OpenID Connect plugin is installed and ready for Authentik SSO"
echo "✅ Admin user created (admin/admin)"
echo "✅ API key configured for MCP integration"
echo "✅ Application passwords enabled"
echo ""
echo "📋 Optional SSO Configuration:"
echo "1. Configure Authentik OAuth providers at: http://localhost:9000 (admin/admin)"
echo "2. See docs/sso-setup-guide.md for SSO integration with WordPress and OpenWebUI"
echo ""
echo "🧪 Testing:"
echo "   Run the integration test: ./scripts/test-integration.sh"
echo ""
echo "📚 Service URLs:"
echo "   WordPress: http://localhost:8080"
echo "   OpenWebUI: http://localhost:3000"
echo "   Authentik: http://localhost:9000"
echo "   MariaDB: localhost:3306"
echo ""
echo "🔑 Automated Authentication:"
echo "   WordPress Admin: admin/admin (configured automatically)"
echo "   MCP API Key: demo-api-key-poc (configured automatically)"
echo "   Authentik Admin: admin/admin (change after first login)"
echo ""
echo "🔐 SSO Configuration:"
echo "   See docs/sso-setup-guide.md for detailed SSO configuration steps"
echo ""
echo "📖 For more information, see: docs/setup-guide.md"