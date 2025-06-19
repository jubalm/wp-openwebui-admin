#!/bin/bash
set -euo pipefail

echo "🚀 Starting Authentik OAuth Configuration..."

# Configuration variables
AUTHENTIK_BASE_URL="${AUTHENTIK_URL:-http://authentik-server:9000}"
WORDPRESS_CLIENT_ID="${WORDPRESS_OAUTH_CLIENT_ID:-wordpress}"
WORDPRESS_CLIENT_SECRET="${WORDPRESS_OAUTH_CLIENT_SECRET:-wordpress-secret-auto}"
OPENWEBUI_CLIENT_ID="${OPENWEBUI_OAUTH_CLIENT_ID:-openwebui}"
OPENWEBUI_CLIENT_SECRET="${OPENWEBUI_OAUTH_CLIENT_SECRET:-openwebui-secret-auto}"
SITE_URL="${SITE_URL:-http://localhost:8080}"
WEBUI_URL="${WEBUI_URL:-http://localhost:3000}"

echo "⏳ Waiting for Authentik to be ready..."
sleep 30

# Create a configuration file that can be used by other services
cat > /tmp/oauth_config.json << EOF
{
  "wordpress": {
    "client_id": "$WORDPRESS_CLIENT_ID",
    "client_secret": "$WORDPRESS_CLIENT_SECRET",
    "issuer_url": "$AUTHENTIK_BASE_URL/application/o/wordpress/",
    "authorization_endpoint": "$AUTHENTIK_BASE_URL/application/o/authorize/",
    "token_endpoint": "$AUTHENTIK_BASE_URL/application/o/token/",
    "userinfo_endpoint": "$AUTHENTIK_BASE_URL/application/o/userinfo/",
    "end_session_endpoint": "$AUTHENTIK_BASE_URL/if/session-end/"
  },
  "openwebui": {
    "client_id": "$OPENWEBUI_CLIENT_ID",
    "client_secret": "$OPENWEBUI_CLIENT_SECRET",
    "authorization_url": "$AUTHENTIK_BASE_URL/application/o/authorize/",
    "token_url": "$AUTHENTIK_BASE_URL/application/o/token/",
    "userinfo_url": "$AUTHENTIK_BASE_URL/application/o/userinfo/"
  }
}
EOF

echo "✅ OAuth configuration created successfully!"
echo "🎯 Configuration saved to /tmp/oauth_config.json"

# Create a simple status file to indicate completion
echo "Configuration completed at $(date)" > /tmp/authentik_config_status.txt

echo "🎉 Authentik OAuth configuration completed!"
echo ""
echo "📋 Configuration Summary:"
echo "  WordPress Client ID: $WORDPRESS_CLIENT_ID"
echo "  OpenWebUI Client ID: $OPENWEBUI_CLIENT_ID"
echo "  Site URL: $SITE_URL"
echo "  WebUI URL: $WEBUI_URL"
echo "  Authentik Base URL: $AUTHENTIK_BASE_URL"
echo ""
echo "ℹ️  Note: Manual OAuth application creation in Authentik is still required"
echo "   Visit: $AUTHENTIK_BASE_URL/if/admin/ to create applications"
echo "   WordPress redirect URI: $SITE_URL/wp-admin/admin-ajax.php?action=openid-connect-authorize"
echo "   OpenWebUI redirect URI: $WEBUI_URL/oauth/callback"
echo ""
echo "🔗 For fully automated configuration, see docs/automated-sso-guide.md"

# Keep the container running for a while to allow other services to read the config
sleep 60