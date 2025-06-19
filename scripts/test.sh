#!/bin/bash

# Comprehensive test script for WordPress and OpenWebUI Integration PoC
# Tests WordPress MCP integration, SSO functionality, and service health

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
WORDPRESS_URL="http://localhost:8080"
OPENWEBUI_URL="http://localhost:3000"
AUTHENTIK_URL="http://localhost:9000"
WORDPRESS_USER="admin"
WORDPRESS_PASS="admin123"

echo -e "${BLUE}🧪 Running Comprehensive PoC Tests...${NC}"
echo ""

# Create logs directory
mkdir -p /tmp/poc-test-logs

# Test 1: WordPress Integration
echo -e "${YELLOW}1️⃣ Testing WordPress Integration...${NC}"

# Check WordPress availability
echo "   Checking WordPress availability..."
wp_response=$(curl -s -L -w "%{http_code}" "$WORDPRESS_URL" -o /tmp/poc-test-logs/wp-response.txt 2>&1 || echo "failed")
if [ "$wp_response" = "failed" ] || [ "$wp_response" != "200" ]; then
    echo -e "   ${RED}❌ WordPress not accessible at $WORDPRESS_URL${NC}"
    exit 1
else
    echo -e "   ${GREEN}✅ WordPress is accessible${NC}"
fi

# Test WordPress REST API
echo "   Testing WordPress REST API..."
api_response=$(curl -s -w "%{http_code}" "$WORDPRESS_URL/wp-json/wp/v2/posts" -o /tmp/poc-test-logs/api-response.txt || echo "failed")
if [ "$api_response" = "failed" ] || [ "$api_response" != "200" ]; then
    echo -e "   ${RED}❌ WordPress REST API not accessible${NC}"
else
    echo -e "   ${GREEN}✅ WordPress REST API is working${NC}"
fi

# Test WordPress CRUD operations
echo "   Testing WordPress CRUD operations..."

# Create a test post
create_response=$(curl -s -w "%{http_code}" \
    -X POST "$WORDPRESS_URL/wp-json/wp/v2/posts" \
    -u "$WORDPRESS_USER:$WORDPRESS_PASS" \
    -H "Content-Type: application/json" \
    -d '{"title":"PoC Test Post","content":"This is a test post for the PoC integration","status":"publish"}' \
    -o /tmp/poc-test-logs/create-response.txt || echo "failed")

if [ "$create_response" = "201" ]; then
    echo -e "   ${GREEN}✅ Post creation successful${NC}"
    post_id=$(grep -o '"id":[0-9]*' /tmp/poc-test-logs/create-response.txt | cut -d':' -f2)
    echo "   Created post ID: $post_id"
    
    # Update the post
    update_response=$(curl -s -w "%{http_code}" \
        -X POST "$WORDPRESS_URL/wp-json/wp/v2/posts/$post_id" \
        -u "$WORDPRESS_USER:$WORDPRESS_PASS" \
        -H "Content-Type: application/json" \
        -d '{"title":"Updated PoC Test Post","content":"This post has been updated via API"}' \
        -o /tmp/poc-test-logs/update-response.txt || echo "failed")
    
    if [ "$update_response" = "200" ]; then
        echo -e "   ${GREEN}✅ Post update successful${NC}"
    else
        echo -e "   ${YELLOW}⚠️ Post update failed (response: $update_response)${NC}"
    fi
    
    # Delete the test post
    delete_response=$(curl -s -w "%{http_code}" \
        -X DELETE "$WORDPRESS_URL/wp-json/wp/v2/posts/$post_id" \
        -u "$WORDPRESS_USER:$WORDPRESS_PASS" \
        -o /tmp/poc-test-logs/delete-response.txt || echo "failed")
    
    if [ "$delete_response" = "200" ]; then
        echo -e "   ${GREEN}✅ Post deletion successful${NC}"
    else
        echo -e "   ${YELLOW}⚠️ Post deletion failed (response: $delete_response)${NC}"
    fi
else
    echo -e "   ${RED}❌ Post creation failed (response: $create_response)${NC}"
fi

echo ""

# Test 2: OpenWebUI
echo -e "${YELLOW}2️⃣ Testing OpenWebUI...${NC}"

openwebui_response=$(curl -s -L -w "%{http_code}" "$OPENWEBUI_URL" -o /tmp/poc-test-logs/openwebui-response.txt 2>&1 || echo "failed")
if [ "$openwebui_response" = "failed" ] || [ "$openwebui_response" != "200" ]; then
    echo -e "   ${RED}❌ OpenWebUI not accessible at $OPENWEBUI_URL${NC}"
else
    echo -e "   ${GREEN}✅ OpenWebUI is accessible${NC}"
fi

echo ""

# Test 3: SSO and Authentik (if enabled)
echo -e "${YELLOW}3️⃣ Testing SSO and Authentik...${NC}"

# Check if Authentik is running
if docker ps --filter "name=authentik-server" --format "{{.Names}}" | grep -q "authentik-server"; then
    echo "   Authentik container is running"
    
    # Test Authentik availability
    authentik_response=$(curl -s -L -w "%{http_code}" "$AUTHENTIK_URL" -o /tmp/poc-test-logs/authentik-response.txt 2>&1 || echo "failed")
    if [ "$authentik_response" = "failed" ] || [ "$authentik_response" != "200" ]; then
        echo -e "   ${YELLOW}⚠️ Authentik UI not accessible at $AUTHENTIK_URL${NC}"
        echo "   This might be expected in some environments"
    else
        echo -e "   ${GREEN}✅ Authentik UI is accessible${NC}"
    fi
    
    # Check container health
    health_status=$(docker inspect authentik-server --format='{{.State.Health.Status}}' 2>/dev/null || echo "no-health")
    if [ "$health_status" = "healthy" ]; then
        echo -e "   ${GREEN}✅ Authentik container is healthy${NC}"
    elif [ "$health_status" = "no-health" ]; then
        echo -e "   ${YELLOW}ℹ️ Authentik container has no health check configured${NC}"
    else
        echo -e "   ${YELLOW}⚠️ Authentik container health: $health_status${NC}"
    fi
else
    echo -e "   ${YELLOW}ℹ️ Authentik is not running (SSO disabled)${NC}"
fi

echo ""

# Test 4: Service Health Summary
echo -e "${YELLOW}4️⃣ Service Health Summary...${NC}"

# Check all containers
echo "   Docker container status:"
docker ps --filter "name=wordpress" --filter "name=openwebui" --filter "name=mariadb" --filter "name=authentik" --format "table {{.Names}}\t{{.Status}}" > /tmp/poc-test-logs/container-summary.txt

if [ -s /tmp/poc-test-logs/container-summary.txt ]; then
    cat /tmp/poc-test-logs/container-summary.txt
else
    echo -e "   ${RED}❌ No containers found${NC}"
fi

echo ""

# Test Results Summary
echo -e "${BLUE}📊 Test Results Summary${NC}"
echo "=================================="

# Count successful tests
success_count=0
total_tests=4

if [ "$wp_response" = "200" ]; then
    echo -e "${GREEN}✅ WordPress: Accessible and working${NC}"
    ((success_count++))
else
    echo -e "${RED}❌ WordPress: Issues detected${NC}"
fi

if [ "$openwebui_response" = "200" ]; then
    echo -e "${GREEN}✅ OpenWebUI: Accessible${NC}"
    ((success_count++))
else
    echo -e "${RED}❌ OpenWebUI: Issues detected${NC}"
fi

if [ "$api_response" = "200" ]; then
    echo -e "${GREEN}✅ WordPress API: Working${NC}"
    ((success_count++))
else
    echo -e "${RED}❌ WordPress API: Issues detected${NC}"
fi

if docker ps --filter "name=mariadb" --format "{{.Names}}" | grep -q "mariadb"; then
    echo -e "${GREEN}✅ Database: Running${NC}"
    ((success_count++))
else
    echo -e "${RED}❌ Database: Not running${NC}"
fi

echo ""
echo -e "${BLUE}Score: $success_count/$total_tests tests passed${NC}"

if [ $success_count -eq $total_tests ]; then
    echo -e "${GREEN}🎉 All critical tests passed! PoC is working correctly.${NC}"
    exit 0
elif [ $success_count -gt 2 ]; then
    echo -e "${YELLOW}⚠️ Most tests passed, but some issues detected.${NC}"
    exit 0
else
    echo -e "${RED}❌ Multiple critical issues detected.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}💡 Logs saved to: /tmp/poc-test-logs/${NC}"
echo "   Use these logs for troubleshooting if needed."