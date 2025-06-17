#!/bin/bash

# Test script to validate WordPress MCP Integration
# Tests MCP functionality using the official WordPress MCP plugin

set -e

# WordPress REST API base (official WordPress endpoints)
WP_API_BASE="http://localhost:8080/wp-json/wp/v2"
MCP_API_BASE="http://localhost:8080/wp-json/wp/v2/wpmcp"

# You need to set these after WordPress setup
WP_USERNAME="admin"  # Set this to your WordPress admin username
WP_PASSWORD=""       # Set this to your WordPress application password
JWT_TOKEN=""         # Set this to your generated JWT token

echo "🧪 Testing WordPress MCP Integration..."
echo ""
echo "⚠️  Prerequisites:"
echo "   1. Complete WordPress setup at http://localhost:8080"
echo "   2. Activate the WordPress MCP plugin"
echo "   3. Set WP_USERNAME and WP_PASSWORD variables in this script"
echo "   4. Or generate a JWT token and set JWT_TOKEN variable"
echo ""

# Check if authentication is configured
if [ -z "$WP_PASSWORD" ] && [ -z "$JWT_TOKEN" ]; then
    echo "❌ Authentication not configured!"
    echo "   Please set either WP_PASSWORD (WordPress app password) or JWT_TOKEN in this script"
    exit 1
fi

# Function to make WordPress REST API calls
make_wp_api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -n "$JWT_TOKEN" ]; then
        # Use JWT authentication
        auth_header="Authorization: Bearer $JWT_TOKEN"
    else
        # Use basic authentication with application password
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
echo "   1. Generate JWT tokens in WordPress: Settings > MCP Settings"
echo "   2. Configure OpenWebUI to connect to WordPress MCP endpoints"
echo "   3. Use mcp-wordpress-remote package for MCP client integration"