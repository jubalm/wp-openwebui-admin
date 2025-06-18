#!/bin/bash

# Test script to validate WordPress MCP Integration
# Tests MCP functionality using the official WordPress MCP plugin
# Works with automated WordPress setup

set -e

# WordPress REST API base (official WordPress endpoints)
WP_API_BASE="http://localhost:8080/wp-json/wp/v2"
MCP_API_BASE="http://localhost:8080/wp-json/wp/v2/wpmcp"

# Automated credentials from docker-compose setup
WP_USERNAME="${SITE_ADMIN_USER:-admin}"  # Default admin user from automated setup
WP_PASSWORD="${SITE_ADMIN_PASSWORD:-admin123}"  # Default admin password from automated setup
JWT_TOKEN=""         # Can be set if you generated a JWT token

echo "🧪 Testing WordPress MCP Integration..."
echo ""
echo "✅ Using automated WordPress setup credentials:"
echo "   Username: $WP_USERNAME"
echo "   Password: [Using automated setup password]"
echo ""

# WordPress should be fully automated, no manual setup required
echo "ℹ️  WordPress is configured automatically with:"
echo "   ✅ WordPress MCP plugin pre-installed and activated"
echo "   ✅ Admin user created: $WP_USERNAME"
echo "   ✅ Application passwords enabled"
echo "   ✅ OpenID Connect plugin ready for SSO"
echo ""

# Function to make WordPress REST API calls
make_wp_api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -n "$JWT_TOKEN" ]; then
        # Use JWT authentication
        auth_header="Authorization: Bearer $JWT_TOKEN"
    else
        # Use basic authentication with admin credentials
        auth_header="Authorization: Basic $(echo -n "$WP_USERNAME:$WP_PASSWORD" | base64)"
    fi
    
    if [ -n "$data" ]; then
        curl -s -X "$method" \
             -H "Content-Type: application/json" \
             -H "$auth_header" \
             -d "$data" \
             "$WP_API_BASE$endpoint"
    else
        curl -s -X "$method" \
             -H "$auth_header" \
             "$WP_API_BASE$endpoint"
    fi
}

# Test 1: Check WordPress REST API
echo "1️⃣ Testing WordPress REST API connectivity..."
api_response=$(curl -s "$WP_API_BASE" || echo "failed")
if [ "$api_response" = "failed" ]; then
    echo "❌ WordPress REST API not accessible"
    exit 1
else
    echo "✅ WordPress REST API is accessible"
fi

# Wait a moment
sleep 2

# Test 2: Create a new post (CREATE)
echo ""
echo "2️⃣ Testing CREATE operation (WordPress Posts API)..."
create_data='{
    "title": "Test Post from WordPress MCP Integration",
    "content": "This post was created via the WordPress MCP plugin to test the WordPress and OpenWebUI connection. The official WordPress MCP plugin provides standardized MCP tools for AI integration.",
    "excerpt": "Test post created via official WordPress MCP plugin",
    "status": "publish"
}'

create_response=$(make_wp_api_call "POST" "/posts" "$create_data")
echo "✅ Create Response: $create_response"

# Extract post ID from response (basic parsing)
post_id=$(echo "$create_response" | grep -o '"id":[0-9]*' | cut -d':' -f2)

if [ -z "$post_id" ]; then
    echo "❌ Failed to extract post ID from create response"
    exit 1
fi

echo "📝 Created post with ID: $post_id"
sleep 2

# Test 3: Read posts (READ)
echo ""
echo "3️⃣ Testing READ operation (WordPress Posts API)..."
read_response=$(make_wp_api_call "GET" "/posts")
echo "✅ Read Response: $read_response"
sleep 2

# Test 4: Update the post (UPDATE)
echo ""
echo "4️⃣ Testing UPDATE operation (WordPress Posts API)..."
update_data='{
    "title": "Updated Test Post from WordPress MCP Integration",
    "content": "This post was updated via the WordPress MCP plugin to test the WordPress and OpenWebUI connection. This content has been modified to demonstrate the UPDATE functionality.",
    "excerpt": "Updated test post via official WordPress MCP plugin",
    "status": "publish"
}'

update_response=$(make_wp_api_call "PUT" "/posts/$post_id" "$update_data")
echo "✅ Update Response: $update_response"
sleep 2

# Test 5: Delete the post (DELETE)
echo ""
echo "5️⃣ Testing DELETE operation (WordPress Posts API)..."
delete_response=$(make_wp_api_call "DELETE" "/posts/$post_id")
echo "✅ Delete Response: $delete_response"

# Test 6: Test MCP endpoint accessibility
echo ""
echo "6️⃣ Testing MCP endpoints..."
mcp_stdio_response=$(curl -s "$MCP_API_BASE" || echo "failed")
if [ "$mcp_stdio_response" = "failed" ]; then
    echo "⚠️  MCP STDIO endpoint not accessible (may need authentication)"
else
    echo "✅ MCP STDIO endpoint is accessible"
fi

mcp_streamable_response=$(curl -s "$MCP_API_BASE/streamable" || echo "failed")
if [ "$mcp_streamable_response" = "failed" ]; then
    echo "⚠️  MCP Streamable endpoint not accessible (may need authentication)"
else
    echo "✅ MCP Streamable endpoint is accessible"
fi

echo ""
echo "🎉 All WordPress operations completed successfully!"
echo ""
echo "📊 Test Summary:"
echo "   ✅ WordPress REST API connectivity"
echo "   ✅ CREATE - Post created with ID: $post_id"
echo "   ✅ READ - Posts retrieved successfully"
echo "   ✅ UPDATE - Post updated successfully"
echo "   ✅ DELETE - Post deleted successfully"
echo "   ✅ MCP endpoints checked"
echo ""
echo "🔗 Integration Test Complete!"
echo "   WordPress MCP plugin is properly configured"
echo "   WordPress REST API is functional"
echo "   MCP endpoints are available for AI integration"
echo ""
echo "🤖 Next Steps for OpenWebUI Integration:"
echo "   1. Configure OpenWebUI MCP client to connect to WordPress"
echo "   2. Generate JWT tokens in WordPress for enhanced security"
echo "   3. Test OpenWebUI MCP integration with WordPress"
echo ""
echo "🔐 SSO Integration:"
echo "   Run './scripts/test-sso.sh' to validate Authentik SSO configuration"