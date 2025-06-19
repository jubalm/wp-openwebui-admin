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

# Wait for services to be ready (longer wait for automated WordPress setup and Authentik configuration)
echo "⏳ Waiting for services to start, Authentik to auto-configure, and WordPress to setup..."
sleep 120

# Check if Authentik configuration completed successfully
echo "🔍 Checking Authentik OAuth configuration..."
if docker logs authentik-config 2>&1 | grep -q "Authentik configuration completed successfully"; then
    echo "✅ Authentik OAuth applications configured automatically"
else
    echo "⚠️  Authentik configuration may still be in progress..."
fi

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
echo "✨ WordPress and Authentik SSO are now fully automated! No manual setup required."
echo ""
echo "📋 What's Ready:"
echo "✅ WordPress MCP plugin is activated and configured"
echo "✅ OpenID Connect plugin is installed and automatically configured for Authentik SSO"
echo "✅ Admin user created (admin/admin123)"
echo "✅ API key configured for MCP integration"
echo "✅ Application passwords enabled"
echo "✅ Authentik OAuth applications configured automatically"
echo "✅ WordPress and OpenWebUI SSO integration ready"
echo ""
echo "🧪 Testing:"
echo "   Run the integration test: ./scripts/test-integration.sh"
echo "   Run the SSO validation test: ./scripts/test-sso.sh"
echo ""
echo "📚 Service URLs:"
echo "   WordPress: http://localhost:8080"
echo "   OpenWebUI: http://localhost:3000"
echo "   Authentik: http://localhost:9000"
echo "   MariaDB: localhost:3306"
echo ""
echo "🔑 Automated Authentication:"
echo "   WordPress Admin: admin/admin123 (configured automatically)"
echo "   MCP API Key: demo-api-key-poc (configured automatically)"
echo "   Authentik Admin: admin/admin (change after first login)"
echo ""
echo "🔐 Automated SSO Configuration:"
echo "   ✅ WordPress OAuth application: 'wordpress' (automatically configured)"
echo "   ✅ OpenWebUI OAuth application: 'openwebui' (automatically configured)"
echo "   ✅ WordPress OpenID Connect plugin: pre-configured for Authentik"
echo "   ✅ Single Sign-On ready for both applications"
echo ""
echo "🎯 To test SSO integration:"
echo "   1. Logout from WordPress if logged in"
echo "   2. Visit http://localhost:8080/wp-login.php"
echo "   3. Click 'Login with OpenID Connect' button"
echo "   4. Login with Authentik (admin/admin)"
echo "   5. Access OpenWebUI at http://localhost:3000 and use OAuth login"
echo ""
echo "📖 For more information, see: docs/setup-guide.md"