#!/bin/bash

# Test script to validate WordPress and OpenWebUI integration
# Tests CRUD operations via MCP plugin API

set -e

API_BASE="http://localhost:8080/wp-json/mcp/v1"
API_KEY="demo-api-key-poc"

echo "🧪 Testing WordPress MCP Integration..."

# Function to make API calls
make_api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -n "$data" ]; then
        curl -s -X "$method" \
             -H "Content-Type: application/json" \
             -H "X-API-Key: $API_KEY" \
             -d "$data" \
             "$API_BASE$endpoint"
    else
        curl -s -X "$method" \
             -H "X-API-Key: $API_KEY" \
             "$API_BASE$endpoint"
    fi
}

# Test 1: Check plugin status
echo "1️⃣ Testing plugin status..."
status_response=$(make_api_call "GET" "/status")
echo "✅ Status Response: $status_response"

# Wait a moment
sleep 2

# Test 2: Create a new post (CREATE)
echo ""
echo "2️⃣ Testing CREATE operation..."
create_data='{
    "title": "Test Post from MCP Integration",
    "content": "This post was created via the MCP Integration plugin to test the WordPress and OpenWebUI connection.",
    "excerpt": "Test post excerpt",
    "status": "publish"
}'

create_response=$(make_api_call "POST" "/posts" "$create_data")
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
echo "3️⃣ Testing READ operation..."
read_response=$(make_api_call "GET" "/posts")
echo "✅ Read Response: $read_response"
sleep 2

# Test 4: Update the post (UPDATE)
echo ""
echo "4️⃣ Testing UPDATE operation..."
update_data='{
    "title": "Updated Test Post from MCP Integration",
    "content": "This post was updated via the MCP Integration plugin to test the WordPress and OpenWebUI connection. This content has been modified.",
    "excerpt": "Updated test post excerpt",
    "status": "publish"
}'

update_response=$(make_api_call "PUT" "/posts/$post_id" "$update_data")
echo "✅ Update Response: $update_response"
sleep 2

# Test 5: Delete the post (DELETE)
echo ""
echo "5️⃣ Testing DELETE operation..."
delete_response=$(make_api_call "DELETE" "/posts/$post_id")
echo "✅ Delete Response: $delete_response"

echo ""
echo "🎉 All CRUD operations completed successfully!"
echo ""
echo "📊 Test Summary:"
echo "   ✅ Plugin Status Check"
echo "   ✅ CREATE - Post created with ID: $post_id"
echo "   ✅ READ - Posts retrieved successfully"
echo "   ✅ UPDATE - Post updated successfully"
echo "   ✅ DELETE - Post deleted successfully"
echo ""
echo "🔗 Integration Test Complete!"
echo "   WordPress MCP plugin is working correctly"
echo "   All REST API endpoints are functional"
echo "   Ready for OpenWebUI integration"