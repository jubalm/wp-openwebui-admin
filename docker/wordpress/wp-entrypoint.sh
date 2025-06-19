#!/bin/bash
set -euo pipefail

echo "Starting WordPress with custom entrypoint..."

# Start WordPress setup in background
{
    # Wait for WordPress and database to be ready
    echo "Waiting for WordPress to be ready..."
    sleep 10  # Give WordPress time to start
    
    # Wait for database connection
    echo "Waiting for database connection..."
    # Add detailed logging for database connection check
    until wp --allow-root --path="/var/www/html" db check 2>/dev/null; do
        echo "Database not ready, waiting..."
        sleep 3
    done

    echo "Database connection established!"

    # Ensure WordPress installation proceeds only if database is ready
    if ! wp --allow-root --path="/var/www/html" core is-installed 2>/dev/null; then
        echo "Configuring WordPress..."
        
        # Install WordPress
        wp --allow-root --path="/var/www/html" core install \
            --url="${SITE_URL:-http://localhost:8080}" \
            --title="${SITE_TITLE:-WordPress MCP Admin}" \
            --admin_user="${SITE_ADMIN_USER:-admin}" \
            --admin_password="${SITE_ADMIN_PASSWORD:-admin123}" \
            --admin_email="${SITE_ADMIN_EMAIL:-admin@localhost}" \
            --skip-email
        
        echo "WordPress site updated successfully!"
        
        # Activate plugins
        echo "Activating plugins..."
        
        # Activate wordpress-mcp plugin
        if wp --allow-root --path="/var/www/html" plugin list --name=wordpress-mcp --status=inactive 2>/dev/null | grep -q wordpress-mcp; then
            wp --allow-root --path="/var/www/html" plugin activate wordpress-mcp
            echo "wordpress-mcp plugin activated!"
        else
            echo "wordpress-mcp plugin not found or already active"
        fi
        
        # Activate openid-connect-generic plugin
        if wp --allow-root --path="/var/www/html" plugin list --name=openid-connect-generic --status=inactive 2>/dev/null | grep -q openid-connect-generic; then
            wp --allow-root --path="/var/www/html" plugin activate openid-connect-generic
            echo "openid-connect-generic plugin activated!"
        else
            echo "openid-connect-generic plugin not found or already active"
        fi
        
        echo "All plugins processed!"
        
        # Configure OpenID Connect plugin if Authentik is enabled
        if [ "${ENABLE_AUTHENTIK_SSO:-false}" = "true" ]; then
            echo "Configuring OpenID Connect plugin for Authentik SSO..."
            
            # Wait for Authentik configuration to be available
            if [ -f "/tmp/oauth_config.json" ]; then
                echo "OAuth configuration found, applying settings..."
                
                # Set OpenID Connect plugin options
                AUTHENTIK_BASE_URL="${AUTHENTIK_URL:-http://localhost:9000}"
                WORDPRESS_CLIENT_ID="${WORDPRESS_OAUTH_CLIENT_ID:-wordpress}"
                WORDPRESS_CLIENT_SECRET="${WORDPRESS_OAUTH_CLIENT_SECRET:-wordpress-secret-auto}"
                
                # Configure the plugin
                wp --allow-root --path="/var/www/html" option update openid_connect_generic_settings '{"login_type":"button","client_id":"'$WORDPRESS_CLIENT_ID'","client_secret":"'$WORDPRESS_CLIENT_SECRET'","scope":"openid profile email","endpoint_login":"'$AUTHENTIK_BASE_URL'/application/o/authorize/","endpoint_userinfo":"'$AUTHENTIK_BASE_URL'/application/o/userinfo/","endpoint_token":"'$AUTHENTIK_BASE_URL'/application/o/token/","endpoint_end_session":"'$AUTHENTIK_BASE_URL'/if/session-end/","identity_key":"preferred_username","no_sslverify":1,"http_request_timeout":5,"enforce_privacy":0,"alternate_redirect_uri":0,"nickname_key":"preferred_username","email_format":"{email}","displayname_format":"{given_name} {family_name}","identify_with_username":0,"state_time_limit":180,"link_existing_users":1,"create_if_does_not_exist":1,"redirect_user_back":1,"redirect_on_logout":1,"enable_logging":0,"log_limit":1000}' --format=json
                
                echo "OpenID Connect plugin configured for Authentik SSO!"
            else
                echo "OAuth configuration not found, skipping OpenID Connect setup..."
            fi
        fi
        
    else
        echo "WordPress is already installed!"
    fi

    echo "WordPress setup complete! Site available at ${SITE_URL:-http://localhost:8080}"
} &

# Run the original WordPress entrypoint
exec docker-entrypoint.sh apache2-foreground
