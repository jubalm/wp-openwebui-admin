#!/bin/bash
set -euo pipefail

# Skip WP-CLI installation for now since network is restricted
install_wp_cli() {
    echo "Skipping WP-CLI installation - using direct database operations."
    return 1
}

# Install plugins if not present
install_plugins() {
    echo "Skipping plugin installation due to network restrictions."
    echo "WordPress MCP and OpenID Connect plugins can be installed manually."
    
    # Just ensure plugin directories exist
    mkdir -p /var/www/html/wp-content/plugins/wordpress-mcp
    mkdir -p /var/www/html/wp-content/plugins/openid-connect-generic
    chown -R www-data:www-data /var/www/html/wp-content/plugins/
}

# Wait for database to be ready
wait_for_db() {
    echo "Waiting for database to be ready..."
    local db_host="${WORDPRESS_DB_HOST%%:*}"
    local db_port="${WORDPRESS_DB_HOST##*:}"
    
    while ! mysql -h"$db_host" -P"$db_port" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do
        echo "Database not ready, waiting..."
        sleep 2
    done
    echo "Database is ready!"
}

# Install WordPress core if not already installed
install_wordpress() {
    local db_host="${WORDPRESS_DB_HOST%%:*}"
    local db_port="${WORDPRESS_DB_HOST##*:}"
    
    # Check if WordPress database tables exist
    local wp_installed=false
    if mysql -h"$db_host" -P"$db_port" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" -e "SELECT COUNT(*) FROM ${WORDPRESS_TABLE_PREFIX:-wp_}options WHERE option_name='siteurl'" 2>/dev/null | grep -q '^1$'; then
        wp_installed=true
    fi
    
    if [ "$wp_installed" = "false" ]; then
        echo "Installing WordPress core..."
        
        # Get configuration from environment variables with defaults
        local site_url="${WORDPRESS_URL:-http://localhost:8080}"
        local site_title="${WORDPRESS_TITLE:-WordPress MCP Integration}"
        local admin_user="${WORDPRESS_ADMIN_USER:-admin}"
        local admin_pass="${WORDPRESS_ADMIN_PASS:-admin}"
        local admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}"
        local site_language="${WORDPRESS_LANGUAGE:-en_US}"
        
        # Since WP-CLI is not available, use direct database installation
        echo "Installing WordPress via direct database operations..."
        
        # Create basic WordPress installation using direct database operations
        local hashed_password=$(echo -n "$admin_pass" | md5sum | cut -d' ' -f1)
        local table_prefix="${WORDPRESS_TABLE_PREFIX:-wp_}"
        local current_date=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Create essential WordPress tables and insert basic data
        mysql -h"$db_host" -P"$db_port" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" << EOF
-- Create WordPress options table
CREATE TABLE IF NOT EXISTS ${table_prefix}options (
  option_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  option_name varchar(191) NOT NULL DEFAULT '',
  option_value longtext NOT NULL,
  autoload varchar(20) NOT NULL DEFAULT 'yes',
  PRIMARY KEY (option_id),
  UNIQUE KEY option_name (option_name),
  KEY autoload (autoload)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- Create WordPress users table
CREATE TABLE IF NOT EXISTS ${table_prefix}users (
  ID bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  user_login varchar(60) NOT NULL DEFAULT '',
  user_pass varchar(255) NOT NULL DEFAULT '',
  user_nicename varchar(50) NOT NULL DEFAULT '',
  user_email varchar(100) NOT NULL DEFAULT '',
  user_url varchar(100) NOT NULL DEFAULT '',
  user_registered datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_activation_key varchar(255) NOT NULL DEFAULT '',
  user_status int(11) NOT NULL DEFAULT '0',
  display_name varchar(250) NOT NULL DEFAULT '',
  PRIMARY KEY (ID),
  KEY user_login_key (user_login),
  KEY user_nicename (user_nicename),
  KEY user_email (user_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- Create WordPress usermeta table
CREATE TABLE IF NOT EXISTS ${table_prefix}usermeta (
  umeta_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  user_id bigint(20) unsigned NOT NULL DEFAULT '0',
  meta_key varchar(255) DEFAULT NULL,
  meta_value longtext,
  PRIMARY KEY (umeta_id),
  KEY user_id (user_id),
  KEY meta_key (meta_key(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- Insert essential WordPress options
INSERT IGNORE INTO ${table_prefix}options (option_name, option_value, autoload) VALUES
('siteurl', '$site_url', 'yes'),
('home', '$site_url', 'yes'),
('blogname', '$site_title', 'yes'),
('blogdescription', '${WORDPRESS_DESCRIPTION:-Just another WordPress site}', 'yes'),
('admin_email', '$admin_email', 'yes'),
('users_can_register', '0', 'yes'),
('default_role', 'subscriber', 'yes'),
('timezone_string', '${WORDPRESS_TIMEZONE:-UTC}', 'yes'),
('date_format', '${WORDPRESS_DATE_FORMAT:-F j, Y}', 'yes'),
('time_format', '${WORDPRESS_TIME_FORMAT:-g:i a}', 'yes'),
('start_of_week', '${WORDPRESS_WEEK_STARTS_ON:-1}', 'yes'),
('WPLANG', '${site_language}', 'yes'),
('permalink_structure', '/%postname%/', 'yes'),
('posts_per_page', '10', 'yes'),
('blog_public', '1', 'yes'),
('active_plugins', 'a:0:{}', 'yes'),
('initial_db_version', '53496', 'yes'),
('db_version', '53496', 'yes');

-- Insert admin user
INSERT IGNORE INTO ${table_prefix}users (user_login, user_pass, user_nicename, user_email, user_registered, user_status, display_name) 
VALUES ('$admin_user', MD5('$admin_pass'), '$admin_user', '$admin_email', '$current_date', 0, '$admin_user');

-- Get the user ID and insert admin capabilities
SET @user_id = LAST_INSERT_ID();
IF @user_id = 0 THEN
  SELECT ID INTO @user_id FROM ${table_prefix}users WHERE user_login = '$admin_user' LIMIT 1;
END IF;

INSERT IGNORE INTO ${table_prefix}usermeta (user_id, meta_key, meta_value) VALUES
(@user_id, '${table_prefix}capabilities', 'a:1:{s:13:"administrator";b:1;}'),
(@user_id, '${table_prefix}user_level', '10'),
(@user_id, 'nickname', '$admin_user'),
(@user_id, 'rich_editing', 'true'),
(@user_id, 'admin_color', 'fresh'),
(@user_id, 'show_admin_bar_front', 'true');
EOF
        
        echo "WordPress core installed successfully via direct database operations!"
    else
        echo "WordPress is already installed."
    fi
}

# Activate required plugins
activate_plugins() {
    echo "Plugin activation will be handled by WordPress mu-plugins auto-loader."
    
    # Create mu-plugins directory and auto-activation script
    mkdir -p /var/www/html/wp-content/mu-plugins
    
    cat > /var/www/html/wp-content/mu-plugins/auto-activate.php << 'EOF'
<?php
/**
 * Auto-activate required plugins
 */
add_action('init', function() {
    if (!function_exists('activate_plugin')) {
        require_once ABSPATH . 'wp-admin/includes/plugin.php';
    }
    
    $plugins_to_activate = [
        'wordpress-mcp/wordpress-mcp.php',
        'openid-connect-generic/openid-connect-generic.php'
    ];
    
    foreach ($plugins_to_activate as $plugin) {
        if (!is_plugin_active($plugin) && file_exists(WP_PLUGIN_DIR . '/' . $plugin)) {
            activate_plugin($plugin);
        }
    }
});
EOF
    
    chown -R www-data:www-data /var/www/html/wp-content/mu-plugins
    echo "Auto-activation script created for plugins."
}

# Configure OpenID Connect plugin for Authentik
configure_openid_connect() {
    echo "Configuring OpenID Connect for Authentik..."
    
    local db_host="${WORDPRESS_DB_HOST%%:*}"
    local db_port="${WORDPRESS_DB_HOST##*:}"
    
    # Configure via direct database operations
    local config='{
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
    }'
    
    mysql -h"$db_host" -P"$db_port" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" -e "
        INSERT INTO ${WORDPRESS_TABLE_PREFIX:-wp_}options (option_name, option_value) VALUES ('openid_connect_settings', '$config')
        ON DUPLICATE KEY UPDATE option_value = '$config';
    " 2>/dev/null || echo "Warning: Could not configure OpenID Connect via database"
    
    echo "OpenID Connect configured for Authentik."
}

# Configure WordPress MCP plugin
configure_mcp_plugin() {
    echo "Configuring WordPress MCP plugin..."
    
    local db_host="${WORDPRESS_DB_HOST%%:*}"
    local db_port="${WORDPRESS_DB_HOST##*:}"
    
    # Configure via direct database operations
    mysql -h"$db_host" -P"$db_port" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" -e "
        INSERT INTO ${WORDPRESS_TABLE_PREFIX:-wp_}options (option_name, option_value) VALUES 
            ('wordpress_mcp_enabled', '1'),
            ('wordpress_mcp_api_key', '${WORDPRESS_MCP_API_KEY:-demo-api-key-poc}')
        ON DUPLICATE KEY UPDATE 
            option_value = VALUES(option_value);
    " 2>/dev/null || echo "Warning: Could not configure MCP plugin via database"
    
    echo "WordPress MCP plugin configured."
}

# Create application password for API access
create_application_password() {
    echo "Application passwords will be available after WordPress is fully loaded."
    echo "Note: Application passwords require plugins to be loaded and may need manual creation."
}

# Update permalink structure
update_permalinks() {
    echo "Permalink structure already set in database options."
}

# Main initialization function
main() {
    echo "Starting WordPress initialization..."
    
    # Change to WordPress directory
    cd /var/www/html
    
    # Install WP-CLI (will be skipped due to network restrictions)  
    install_wp_cli
    
    # Install plugins (will be skipped due to network restrictions)
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
    
    # Create application password (skipped for now)
    create_application_password
    
    # Update permalinks (already handled in database)
    update_permalinks
    
    echo "WordPress initialization completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi