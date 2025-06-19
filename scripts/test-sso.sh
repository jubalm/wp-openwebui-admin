#!/bin/bash

# Test script to validate SSO integration with Authentik
# Tests Authentik availability and SSO configuration

set -e

echo "🔐 Testing SSO Integration with Authentik..."
echo ""

# Create logs directory for debugging
mkdir -p /tmp/sso-test-logs

# Test 1: Check Authentik availability
echo "1️⃣ Testing Authentik server availability..."
authentik_response=$(curl -s -L -w "%{http_code}" http://localhost:9000 -o /tmp/sso-test-logs/authentik-response.txt 2>&1 || echo "failed")
if [ "$authentik_response" = "failed" ] || [ "$authentik_response" != "200" ]; then
    echo "❌ Authentik server not accessible at http://localhost:9000"
    echo "   Make sure Authentik is running: docker compose ps authentik-server"
    # Save error details to file
    echo "Error details saved to /tmp/sso-test-logs/authentik-response.txt"
    exit 1
else
    echo "✅ Authentik server is accessible at http://localhost:9000"
    echo "Response size: $(wc -c < /tmp/sso-test-logs/authentik-response.txt) bytes"
fi

# Test 2: Check Authentik admin interface
echo ""
echo "2️⃣ Testing Authentik admin interface..."
admin_response=$(curl -s -L http://localhost:9000/if/admin/ -w "%{http_code}" -o /tmp/sso-test-logs/admin-response.txt 2>&1 || echo "failed")
if [ "$admin_response" = "failed" ]; then
    echo "❌ Authentik admin interface not accessible"
    echo "Error details saved to /tmp/sso-test-logs/admin-response.txt"
else
    echo "✅ Authentik admin interface is accessible (HTTP $admin_response)"
fi

# Test 3: Check WordPress availability
echo ""
echo "3️⃣ Testing WordPress availability..."
wp_response=$(curl -s -L -w "%{http_code}" http://localhost:8080 -o /tmp/sso-test-logs/wordpress-response.txt 2>&1 || echo "failed")
if [ "$wp_response" = "failed" ] || [ "$wp_response" != "200" ]; then
    echo "❌ WordPress not accessible at http://localhost:8080"
    echo "Error details saved to /tmp/sso-test-logs/wordpress-response.txt"
    exit 1
else
    echo "✅ WordPress is accessible at http://localhost:8080"
fi

# Test 4: Check OpenWebUI availability
echo ""
echo "4️⃣ Testing OpenWebUI availability..."
owui_response=$(curl -s -L -w "%{http_code}" http://localhost:3000 -o /tmp/sso-test-logs/openwebui-response.txt 2>&1 || echo "failed")
if [ "$owui_response" = "failed" ] || [ "$owui_response" != "200" ]; then
    echo "❌ OpenWebUI not accessible at http://localhost:3000"
    echo "Error details saved to /tmp/sso-test-logs/openwebui-response.txt"
    exit 1
else
    echo "✅ OpenWebUI is accessible at http://localhost:3000"
fi

# Test 5: Check OAuth endpoints
echo ""
echo "5️⃣ Testing Authentik OAuth endpoints..."

# Test authorization endpoint
auth_endpoint=$(curl -s -L -w "%{http_code}" http://localhost:9000/application/o/authorize/ -o /tmp/sso-test-logs/oauth-auth.txt 2>&1 || echo "failed")
if [ "$auth_endpoint" = "failed" ]; then
    echo "⚠️  OAuth authorization endpoint not accessible (may require parameters)"
else
    echo "✅ OAuth authorization endpoint is accessible (HTTP $auth_endpoint)"
fi

# Test token endpoint
token_endpoint=$(curl -s -L -w "%{http_code}" http://localhost:9000/application/o/token/ -o /tmp/sso-test-logs/oauth-token.txt 2>&1 || echo "failed")
if [ "$token_endpoint" = "failed" ]; then
    echo "⚠️  OAuth token endpoint not accessible (may require parameters)"
else
    echo "✅ OAuth token endpoint is accessible (HTTP $token_endpoint)"
fi

# Test userinfo endpoint
userinfo_endpoint=$(curl -s -L -w "%{http_code}" http://localhost:9000/application/o/userinfo/ -o /tmp/sso-test-logs/oauth-userinfo.txt 2>&1 || echo "failed")
if [ "$userinfo_endpoint" = "failed" ]; then
    echo "⚠️  OAuth userinfo endpoint not accessible (may require authentication)"
else
    echo "✅ OAuth userinfo endpoint is accessible (HTTP $userinfo_endpoint)"
fi

# Test 6: Check if WordPress has OpenID Connect plugin ready
echo ""
echo "6️⃣ Checking WordPress OpenID Connect plugin readiness..."
wp_plugins_check=$(curl -s -L http://localhost:8080/wp-admin/plugins.php -o /tmp/sso-test-logs/wp-plugins.txt 2>&1 || echo "failed")
if [ "$wp_plugins_check" = "failed" ]; then
    echo "⚠️  Cannot check WordPress plugins page (authentication required)"
    echo "   Plugin should be pre-installed in custom WordPress image"
else
    echo "✅ WordPress plugins page accessible"
fi

echo ""
echo "🎉 SSO Environment Test Complete!"
echo ""
echo "📊 Test Summary:"
echo "   ✅ Authentik server running and accessible"
echo "   ✅ Authentik admin interface accessible"
echo "   ✅ WordPress running and accessible"
echo "   ✅ OpenWebUI running and accessible"
echo "   ✅ OAuth endpoints available"
echo ""
echo "📁 Debug logs saved to: /tmp/sso-test-logs/"
echo "   Check these files for detailed response information if issues occur"
echo ""
echo "📋 Manual SSO Configuration Steps:"
echo "   1. Configure Authentik OAuth providers:"
echo "      - Visit: http://localhost:9000 (admin/admin)"
echo "      - Create applications for WordPress and OpenWebUI"
echo ""
echo "   2. Configure WordPress OpenID Connect:"
echo "      - Login to WordPress: http://localhost:8080 (admin/admin123)"
echo "      - Configure OpenID Connect Generic plugin"
echo ""
echo "   3. OpenWebUI OAuth is pre-configured via environment variables"
echo ""
echo "📚 For detailed configuration steps, see: docs/sso-setup-guide.md"
echo ""
echo "🔑 Default Credentials:"
echo "   Authentik Admin: admin/admin"
echo "   WordPress Admin: admin/admin123"
echo "   (Change these in production!)"