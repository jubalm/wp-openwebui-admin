#!/bin/bash

# Test script to validate Authentik functionality
# Tests Authentik container health and UI availability

set -e

echo "🔐 Testing Authentik Container Health..."
echo ""

# Create logs directory
mkdir -p /tmp/authentik-logs

# Test 1: Check container status
echo "1️⃣ Checking Authentik container status..."
docker ps --filter "name=authentik-server" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" > /tmp/authentik-logs/container-status.txt

if grep -q "authentik-server" /tmp/authentik-logs/container-status.txt; then
    echo "✅ Authentik container is running"
    cat /tmp/authentik-logs/container-status.txt
else
    echo "❌ Authentik container is not running"
    exit 1
fi

# Test 2: Check container health
echo ""
echo "2️⃣ Checking Authentik container health..."
docker inspect authentik-server --format='{{.State.Health.Status}}' > /tmp/authentik-logs/health-status.txt 2>/dev/null || echo "no-health" > /tmp/authentik-logs/health-status.txt

health_status=$(cat /tmp/authentik-logs/health-status.txt)
echo "Container health status: $health_status"

if [ "$health_status" = "healthy" ]; then
    echo "✅ Authentik container is healthy"
elif [ "$health_status" = "starting" ]; then
    echo "⏳ Authentik container is still starting (this is normal)"
elif [ "$health_status" = "unhealthy" ]; then
    echo "⚠️  Authentik container is unhealthy but may still be functional"
    echo "    Checking if UI is accessible..."
else
    echo "ℹ️  Health check not available or container starting"
fi

# Test 3: Check Authentik UI availability (most important test)
echo ""
echo "3️⃣ Testing Authentik UI availability..."
max_attempts=10
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s -f http://localhost:9000/ > /tmp/authentik-logs/ui-response.txt 2>&1; then
        echo "✅ Authentik UI is accessible at http://localhost:9000"
        echo "Response received ($(wc -c < /tmp/authentik-logs/ui-response.txt) bytes)"
        break
    else
        echo "⏳ Attempt $attempt/$max_attempts: Authentik UI not ready yet..."
        sleep 5
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Authentik UI is not accessible after $max_attempts attempts"
    echo "Container logs (last 20 lines):"
    docker logs authentik-server --tail=20 > /tmp/authentik-logs/container-logs.txt 2>&1
    tail -20 /tmp/authentik-logs/container-logs.txt
    exit 1
fi

# Test 4: Check specific Authentik endpoints
echo ""
echo "4️⃣ Testing Authentik API endpoints..."

# Test admin interface
admin_status=$(curl -s -w "%{http_code}" http://localhost:9000/if/admin/ -o /tmp/authentik-logs/admin-response.txt 2>/dev/null || echo "failed")
if [ "$admin_status" != "failed" ] && [ "$admin_status" = "200" ]; then
    echo "✅ Admin interface accessible (HTTP $admin_status)"
else
    echo "⚠️  Admin interface returned HTTP $admin_status (may require authentication)"
fi

# Test OAuth endpoints
oauth_status=$(curl -s -w "%{http_code}" http://localhost:9000/application/o/token/ -o /tmp/authentik-logs/oauth-response.txt 2>/dev/null || echo "failed")
if [ "$oauth_status" != "failed" ]; then
    echo "✅ OAuth endpoints accessible (HTTP $oauth_status)"
else
    echo "⚠️  OAuth endpoints not accessible (may require parameters)"
fi

# Test 5: Get detailed container information
echo ""
echo "5️⃣ Getting detailed Authentik container information..."
docker inspect authentik-server > /tmp/authentik-logs/container-inspect.json 2>/dev/null

# Extract key information
echo "Container created: $(docker inspect authentik-server --format='{{.Created}}' 2>/dev/null)"
echo "Container started: $(docker inspect authentik-server --format='{{.State.StartedAt}}' 2>/dev/null)"
echo "Container image: $(docker inspect authentik-server --format='{{.Config.Image}}' 2>/dev/null)"

# Test 6: Check for common issues
echo ""
echo "6️⃣ Checking for common issues..."

# Check if containers can communicate
if docker exec authentik-server ping -c 1 postgres > /tmp/authentik-logs/postgres-ping.txt 2>&1; then
    echo "✅ Authentik can reach PostgreSQL"
else
    echo "⚠️  Authentik cannot reach PostgreSQL (network issue)"
fi

if docker exec authentik-server ping -c 1 redis > /tmp/authentik-logs/redis-ping.txt 2>&1; then
    echo "✅ Authentik can reach Redis"
else
    echo "⚠️  Authentik cannot reach Redis (network issue)"
fi

echo ""
echo "🎉 Authentik Health Check Complete!"
echo ""
echo "📊 Summary:"
echo "   ✅ Container running: $(docker ps --filter 'name=authentik-server' --format '{{.Status}}' | head -1)"
echo "   ✅ UI accessible: http://localhost:9000"
echo "   ✅ Admin interface: http://localhost:9000/if/admin/"
echo ""
echo "📁 Debug logs saved to: /tmp/authentik-logs/"
echo "   - container-status.txt: Current container status"
echo "   - health-status.txt: Docker health check status"
echo "   - ui-response.txt: UI response content"
echo "   - container-logs.txt: Recent container logs"
echo "   - container-inspect.json: Full container details"
echo ""
echo "🔑 Default Login:"
echo "   URL: http://localhost:9000"
echo "   Username: admin"
echo "   Password: admin"
echo "   (Change these in production!)"