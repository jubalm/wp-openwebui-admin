#!/bin/bash

# WordPress and OpenWebUI Integration PoC Setup Script
# This script sets up the local development environment

set -e

echo "🚀 Starting WordPress and OpenWebUI Integration PoC Setup..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p wordpress/{plugins,wp-content,uploads}
mkdir -p openwebui/config
mkdir -p scripts/test

# Set proper permissions
chmod -R 755 wordpress/
chmod -R 755 openwebui/

# Check WordPress MCP plugin
echo "🔌 Checking WordPress MCP plugin..."
if [ ! -f "wordpress/plugins/wordpress-mcp/wordpress-mcp.php" ]; then
    echo "❌ WordPress MCP plugin not found. Please ensure the official wordpress-mcp plugin is in wordpress/plugins/wordpress-mcp/"
    exit 1
fi

# Start Docker containers
echo "🐳 Starting Docker containers..."
docker-compose down --remove-orphans 2>/dev/null || true
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

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
echo "📋 Next Steps:"
echo "1. Complete WordPress setup at: http://localhost:8080"
echo "2. Activate the WordPress MCP plugin in WordPress admin"
echo "3. Configure MCP settings in Settings > MCP Settings"
echo "4. Generate a JWT token for API authentication"
echo "5. Access OpenWebUI at: http://localhost:3000"
echo "6. Run the test script: ./scripts/test-integration.sh"
echo ""
echo "📚 Service URLs:"
echo "   WordPress: http://localhost:8080"
echo "   OpenWebUI: http://localhost:3000"
echo "   MariaDB: localhost:3306"
echo ""
echo "🔑 Authentication:"
echo "   Generate JWT tokens in WordPress admin: Settings > MCP Settings"
echo "   Or use WordPress Application Passwords for basic auth"
echo ""
echo "📖 For more information, see: docs/setup-guide.md"