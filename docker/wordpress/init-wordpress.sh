#!/bin/bash
set -euo pipefail

# Install WP-CLI if not present
install_wp_cli() {
    if ! command -v wp &> /dev/null; then
        echo "Installing WP-CLI..."
        curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/phar/wp-cli.phar 2>/dev/null || {
            echo "Failed to download WP-CLI, trying wget..."
            wget -O wp-cli.phar https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/phar/wp-cli.phar 2>/dev/null || {
                echo "Failed to download WP-CLI. Manual installation required."
                return 1
            }
        }
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
        echo "WP-CLI installed successfully."
    fi
    return 0
}

# Install plugins if not present
install_plugins() {
    echo "Checking and installing required plugins..."
    
    # Install WordPress MCP plugin if not present
    if [ ! -d "/var/www/html/wp-content/plugins/wordpress-mcp" ]; then
        echo "Installing WordPress MCP plugin..."
        cd /tmp
        if wget -O wordpress-mcp.zip https://github.com/Automattic/wordpress-mcp/releases/download/v0.2.2/wordpress-mcp.zip 2>/dev/null; then
            unzip wordpress-mcp.zip
            mv wordpress-mcp /var/www/html/wp-content/plugins/
            rm -f wordpress-mcp.zip
            echo "WordPress MCP plugin installed."
        else
            echo "Warning: Failed to download WordPress MCP plugin."
        fi
    else
        echo "WordPress MCP plugin already present."
    fi
    
    # Install OpenID Connect Generic plugin if not present
    if [ ! -d "/var/www/html/wp-content/plugins/openid-connect-generic" ]; then
        echo "Installing OpenID Connect Generic plugin..."
        cd /tmp
        if wget -O openid-connect-generic.zip https://downloads.wordpress.org/plugin/openid-connect-generic.zip 2>/dev/null; then
            unzip openid-connect-generic.zip
            mv openid-connect-generic /var/www/html/wp-content/plugins/
            rm -f openid-connect-generic.zip
            echo "OpenID Connect Generic plugin installed."
        else
            echo "Warning: Failed to download OpenID Connect Generic plugin."
        fi
    else
        echo "OpenID Connect Generic plugin already present."
    fi
    
    # Set ownership
    chown -R www-data:www-data /var/www/html/wp-content/plugins/
}

# Wait for database to be ready
wait_for_db() {
    echo "Waiting for database to be ready..."
    while ! mysql -h"${WORDPRESS_DB_HOST%%:*}" -P"${WORDPRESS_DB_HOST##*:}" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do
        echo "Database not ready, waiting..."
        sleep 2
    done
    echo "Database is ready!"
}

# Install WordPress core if not already installed
install_wordpress() {
    if ! wp core is-installed --allow-root 2>/dev/null; then
        echo "Installing WordPress core..."
        
        # Ensure wp-cli is available
        if ! command -v wp &> /dev/null; then
            echo "WP-CLI not available, installation will be skipped"
            return 1
        fi
        
        # Get configuration from environment variables with defaults
        local site_url="${WORDPRESS_URL:-http://localhost:8080}"
        local site_title="${WORDPRESS_TITLE:-WordPress MCP Integration}"
        local admin_user="${WORDPRESS_ADMIN_USER:-admin}"
        local admin_pass="${WORDPRESS_ADMIN_PASS:-admin}"
        local admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}"
        local site_language="${WORDPRESS_LANGUAGE:-en_US}"
        
        # Install WordPress
        wp core install \
            --url="$site_url" \
            --title="$site_title" \
            --admin_user="$admin_user" \
            --admin_password="$admin_pass" \
            --admin_email="$admin_email" \
            --skip-email \
            --allow-root
            
        # Set site language if specified
        if [ "$site_language" != "en_US" ]; then
            echo "Setting site language to $site_language..."
            wp language core install "$site_language" --allow-root || echo "Warning: Could not install language $site_language"
            wp site switch-language "$site_language" --allow-root || echo "Warning: Could not switch to language $site_language"
        fi
        
        # Set additional site options from environment variables
        if [ -n "${WORDPRESS_DESCRIPTION:-}" ]; then
            echo "Setting site description: ${WORDPRESS_DESCRIPTION}"
            wp option update blogdescription "${WORDPRESS_DESCRIPTION}" --allow-root
        fi
        
        if [ -n "${WORDPRESS_TIMEZONE:-}" ]; then
            echo "Setting timezone: ${WORDPRESS_TIMEZONE}"
            wp option update timezone_string "${WORDPRESS_TIMEZONE}" --allow-root
        fi
        
        if [ -n "${WORDPRESS_DATE_FORMAT:-}" ]; then
            echo "Setting date format: ${WORDPRESS_DATE_FORMAT}"
            wp option update date_format "${WORDPRESS_DATE_FORMAT}" --allow-root
        fi
        
        if [ -n "${WORDPRESS_TIME_FORMAT:-}" ]; then
            echo "Setting time format: ${WORDPRESS_TIME_FORMAT}"  
            wp option update time_format "${WORDPRESS_TIME_FORMAT}" --allow-root
        fi
        
        if [ -n "${WORDPRESS_WEEK_STARTS_ON:-}" ]; then
            echo "Setting week start day: ${WORDPRESS_WEEK_STARTS_ON}"
            wp option update start_of_week "${WORDPRESS_WEEK_STARTS_ON}" --allow-root
        fi
        
        # Set default theme if specified
        if [ -n "${WORDPRESS_DEFAULT_THEME:-}" ]; then
            echo "Activating theme: ${WORDPRESS_DEFAULT_THEME}"
            wp theme activate "${WORDPRESS_DEFAULT_THEME}" --allow-root || echo "Warning: Could not activate theme ${WORDPRESS_DEFAULT_THEME}"
        fi
            
        echo "WordPress core installed successfully!"
    else
        echo "WordPress is already installed."
    fi
}

# Activate required plugins
activate_plugins() {
    echo "Activating required plugins..."
    
    # Activate WordPress MCP plugin
    if wp plugin is-installed wordpress-mcp --allow-root; then
        wp plugin activate wordpress-mcp --allow-root
        echo "WordPress MCP plugin activated."
    else
        echo "Warning: WordPress MCP plugin not found."
    fi
    
    # Activate OpenID Connect Generic plugin
    if wp plugin is-installed openid-connect-generic --allow-root; then
        wp plugin activate openid-connect-generic --allow-root
        echo "OpenID Connect Generic plugin activated."
    else
        echo "Warning: OpenID Connect Generic plugin not found."
    fi
}

# Configure OpenID Connect plugin for Authentik
configure_openid_connect() {
    echo "Configuring OpenID Connect for Authentik..."
    
    # Set OpenID Connect configuration options
    wp option update openid_connect_settings '{
        "login_type": "auto",
        "client_id": "wordpress",
        "client_secret": "wordpress-secret",
        "scope": "openid profile email",
        "endpoint_login": "http://localhost:9000/application/o/authorize/",
        "endpoint_userinfo": "http://localhost:9000/application/o/userinfo/",
        "endpoint_token": "http://localhost:9000/application/o/token/",
        "endpoint_end_session": "http://localhost:9000/if/session-end/",
        "identity_key": "preferred_username",
        "nickname_key": "preferred_username",
        "email_format": "{email}",
        "displayname_format": "{name}",
        "create_if_does_not_exist": true,
        "redirect_user_back": true,
        "link_existing_users": true,
        "enforce_privacy": false
    }' --format=json --allow-root
    
    echo "OpenID Connect configured for Authentik."
}

# Configure WordPress MCP plugin
configure_mcp_plugin() {
    echo "Configuring WordPress MCP plugin..."
    
    # Enable MCP endpoints
    wp option update wordpress_mcp_enabled 1 --allow-root
    wp option update wordpress_mcp_api_key "${WORDPRESS_MCP_API_KEY:-demo-api-key-poc}" --allow-root
    
    echo "WordPress MCP plugin configured."
}

# Create application password for API access
create_application_password() {
    echo "Creating application password for API access..."
    
    local user="${WORDPRESS_ADMIN_USER:-admin}"
    local app_name="MCP Integration"
    
    # Check if application password already exists
    if ! wp user application-password list "$user" --format=count --allow-root | grep -q "^0$"; then
        echo "Application password already exists."
        return 0
    fi
    
    # Create application password
    local app_pass=$(wp user application-password create "$user" "$app_name" --porcelain --allow-root)
    echo "Application password created: $app_pass"
    
    # Store in environment for other services
    echo "WORDPRESS_APP_PASSWORD=$app_pass" >> /var/www/html/.env
}

# Update permalink structure
update_permalinks() {
    echo "Updating permalink structure..."
    wp rewrite structure '/%postname%/' --allow-root
    wp rewrite flush --allow-root
    echo "Permalinks updated."
}

# Main initialization function
main() {
    echo "Starting WordPress initialization..."
    
    # Change to WordPress directory
    cd /var/www/html
    
    # Install WP-CLI
    install_wp_cli
    
    # Install plugins
    install_plugins
    
    # Wait for database
    wait_for_db
    
    # Install WordPress if needed
    install_wordpress
    
    # Activate plugins
    activate_plugins
    
    # Configure plugins
    configure_openid_connect
    configure_mcp_plugin
    
    # Create application password
    create_application_password
    
    # Update permalinks
    update_permalinks
    
    echo "WordPress initialization completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi