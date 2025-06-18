#!/bin/bash
set -euo pipefail

# Install WP-CLI if not present
install_wp_cli() {
    if ! command -v wp &> /dev/null; then
        echo "Installing WP-CLI..."
        
        # First check if we can reach the internet
        if ! curl -s --connect-timeout 5 https://google.com > /dev/null 2>&1; then
            echo "No internet connectivity detected. Skipping WP-CLI installation."
            return 1
        fi
        
        # Try to download WP-CLI
        if curl -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/phar/wp-cli.phar 2>/dev/null; then
            if [ -f wp-cli.phar ] && [ -s wp-cli.phar ]; then
                chmod +x wp-cli.phar
                mv wp-cli.phar /usr/local/bin/wp
                echo "WP-CLI installed successfully."
                return 0
            else
                echo "Downloaded file is empty or corrupted."
                rm -f wp-cli.phar
            fi
        fi
        
        echo "curl failed, trying wget..."
        if wget -O wp-cli.phar https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/phar/wp-cli.phar 2>/dev/null; then
            if [ -f wp-cli.phar ] && [ -s wp-cli.phar ]; then
                chmod +x wp-cli.phar
                mv wp-cli.phar /usr/local/bin/wp
                echo "WP-CLI installed successfully."
                return 0
            else
                echo "Downloaded file is empty or corrupted."
                rm -f wp-cli.phar
            fi
        fi
        
        echo "Failed to download WP-CLI. Will proceed with direct database operations."
        return 1
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
    # Check if WordPress database tables exist
    local wp_installed=false
    if mysql -h"${WORDPRESS_DB_HOST%%:*}" -P"${WORDPRESS_DB_HOST##*:}" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" -e "SELECT COUNT(*) FROM ${WORDPRESS_TABLE_PREFIX:-wp_}options WHERE option_name='siteurl'" 2>/dev/null | grep -q '^1$'; then
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
        
        # Try WP-CLI first if available
        if command -v wp &> /dev/null; then
            if wp core is-installed --allow-root 2>/dev/null; then
                echo "WordPress is already installed via WP-CLI check."
                wp_installed=true
            else
                echo "Installing WordPress via WP-CLI..."
                # Install WordPress
                if wp core install \
                    --url="$site_url" \
                    --title="$site_title" \
                    --admin_user="$admin_user" \
                    --admin_password="$admin_pass" \
                    --admin_email="$admin_email" \
                    --skip-email \
                    --allow-root 2>/dev/null; then
                    
                    # Set site language if specified
                    if [ "$site_language" != "en_US" ]; then
                        echo "Setting site language to $site_language..."
                        wp language core install "$site_language" --allow-root 2>/dev/null || echo "Warning: Could not install language $site_language"
                        wp site switch-language "$site_language" --allow-root 2>/dev/null || echo "Warning: Could not switch to language $site_language"
                    fi
                    
                    # Set additional site options from environment variables
                    if [ -n "${WORDPRESS_DESCRIPTION:-}" ]; then
                        echo "Setting site description: ${WORDPRESS_DESCRIPTION}"
                        wp option update blogdescription "${WORDPRESS_DESCRIPTION}" --allow-root 2>/dev/null
                    fi
                    
                    if [ -n "${WORDPRESS_TIMEZONE:-}" ]; then
                        echo "Setting timezone: ${WORDPRESS_TIMEZONE}"
                        wp option update timezone_string "${WORDPRESS_TIMEZONE}" --allow-root 2>/dev/null
                    fi
                    
                    if [ -n "${WORDPRESS_DATE_FORMAT:-}" ]; then
                        echo "Setting date format: ${WORDPRESS_DATE_FORMAT}"
                        wp option update date_format "${WORDPRESS_DATE_FORMAT}" --allow-root 2>/dev/null
                    fi
                    
                    if [ -n "${WORDPRESS_TIME_FORMAT:-}" ]; then
                        echo "Setting time format: ${WORDPRESS_TIME_FORMAT}"  
                        wp option update time_format "${WORDPRESS_TIME_FORMAT}" --allow-root 2>/dev/null
                    fi
                    
                    if [ -n "${WORDPRESS_WEEK_STARTS_ON:-}" ]; then
                        echo "Setting week start day: ${WORDPRESS_WEEK_STARTS_ON}"
                        wp option update start_of_week "${WORDPRESS_WEEK_STARTS_ON}" --allow-root 2>/dev/null
                    fi
                    
                    # Set default theme if specified
                    if [ -n "${WORDPRESS_DEFAULT_THEME:-}" ]; then
                        echo "Activating theme: ${WORDPRESS_DEFAULT_THEME}"
                        wp theme activate "${WORDPRESS_DEFAULT_THEME}" --allow-root 2>/dev/null || echo "Warning: Could not activate theme ${WORDPRESS_DEFAULT_THEME}"
                    fi
                    
                    echo "WordPress core installed successfully via WP-CLI!"
                else
                    echo "WP-CLI installation failed, falling back to database method..."
                    command -v wp > /dev/null && rm $(command -v wp) 2>/dev/null || true  # Remove broken wp command
                fi
            fi
        fi
        
        # Fallback to database installation if WP-CLI not available or failed
        if ! command -v wp &> /dev/null; then
            echo "WP-CLI not available. Installing WordPress directly via database..."
            
            # Create basic WordPress installation using direct database operations
            local hashed_password=$(echo -n "$admin_pass" | md5sum | cut -d' ' -f1)
            local table_prefix="${WORDPRESS_TABLE_PREFIX:-wp_}"
            local current_date=$(date '+%Y-%m-%d %H:%M:%S')
            
            # Create essential WordPress tables and insert basic data
            mysql -h"${WORDPRESS_DB_HOST%%:*}" -P"${WORDPRESS_DB_HOST##*:}" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" << EOF
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
('default_ping_status', 'open', 'yes'),
('default_comment_status', 'open', 'yes'),
('posts_per_page', '10', 'yes'),
('rss_use_excerpt', '0', 'yes'),
('mailserver_url', 'mail.example.com', 'yes'),
('mailserver_login', 'login@example.com', 'yes'),
('mailserver_pass', 'password', 'yes'),
('mailserver_port', '110', 'yes'),
('default_category', '1', 'yes'),
('default_post_format', '0', 'yes'),
('link_manager_enabled', '0', 'yes'),
('comment_max_links', '2', 'yes'),
('moderation_notify', '1', 'yes'),
('permalink_structure', '/%postname%/', 'yes'),
('rewrite_rules', '', 'yes'),
('hack_file', '0', 'yes'),
('upload_path', '', 'yes'),
('blog_public', '1', 'yes'),
('default_link_category', '2', 'yes'),
('show_on_front', 'posts', 'yes'),
('tag_base', '', 'yes'),
('show_avatars', '1', 'yes'),
('avatar_rating', 'G', 'yes'),
('upload_url_path', '', 'yes'),
('thumbnail_size_w', '150', 'yes'),
('thumbnail_size_h', '150', 'yes'),
('thumbnail_crop', '1', 'yes'),
('medium_size_w', '300', 'yes'),
('medium_size_h', '300', 'yes'),
('avatar_default', 'mystery', 'yes'),
('large_size_w', '1024', 'yes'),
('large_size_h', '1024', 'yes'),
('image_default_link_type', 'none', 'yes'),
('image_default_size', '', 'yes'),
('image_default_align', '', 'yes'),
('close_comments_for_old_posts', '0', 'yes'),
('close_comments_days_old', '14', 'yes'),
('thread_comments', '1', 'yes'),
('thread_comments_depth', '5', 'yes'),
('page_comments', '0', 'yes'),
('comments_per_page', '50', 'yes'),
('default_comments_page', 'newest', 'yes'),
('comment_order', 'asc', 'yes'),
('sticky_posts', 'a:0:{}', 'yes'),
('widget_categories', 'a:0:{}', 'yes'),
('widget_text', 'a:0:{}', 'yes'),
('widget_rss', 'a:0:{}', 'yes'),
('uninstall_plugins', 'a:0:{}', 'no'),
('timezone_string', '${WORDPRESS_TIMEZONE:-UTC}', 'yes'),
('page_for_posts', '0', 'yes'),
('page_on_front', '0', 'yes'),
('default_post_format', '0', 'yes'),
('link_manager_enabled', '0', 'yes'),
('finished_splitting_shared_terms', '1', 'yes'),
('site_icon', '0', 'yes'),
('medium_large_size_w', '768', 'yes'),
('medium_large_size_h', '0', 'yes'),
('wp_page_for_privacy_policy', '3', 'yes'),
('show_comments_cookies_opt_in', '1', 'yes'),
('admin_email_lifespan', '0', 'yes'),
('disallowed_keys', '', 'no'),
('comment_previously_approved', '1', 'yes'),
('auto_plugin_theme_update_emails', 'a:0:{}', 'no'),
('auto_update_core_dev', 'enabled', 'yes'),
('auto_update_core_minor', 'enabled', 'yes'),
('auto_update_core_major', 'enabled', 'yes'),
('wp_force_deactivated_plugins', 'a:0:{}', 'yes'),
('initial_db_version', '53496', 'yes'),
('db_version', '53496', 'yes'),
('active_plugins', 'a:0:{}', 'yes'),
('theme_switched', '', 'yes');

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
(@user_id, 'first_name', ''),
(@user_id, 'last_name', ''),
(@user_id, 'description', ''),
(@user_id, 'rich_editing', 'true'),
(@user_id, 'syntax_highlighting', 'true'),
(@user_id, 'comment_shortcuts', 'false'),
(@user_id, 'admin_color', 'fresh'),
(@user_id, 'use_ssl', '0'),
(@user_id, 'show_admin_bar_front', 'true'),
(@user_id, 'locale', '');
EOF
            
            echo "WordPress core installed successfully via direct database operations!"
        fi
    else
        echo "WordPress is already installed."
    fi
}

# Activate required plugins
activate_plugins() {
    echo "Activating required plugins..."
    
    if command -v wp &> /dev/null; then
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
    else
        echo "WP-CLI not available. Plugin activation will be handled by WordPress on first load."
        
        # Create a simple activation script that WordPress can run
        cat > /var/www/html/wp-content/mu-plugins/auto-activate.php << 'EOF'
<?php
/**
 * Auto-activate required plugins
 */
add_action('plugins_loaded', function() {
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
        
        # Create mu-plugins directory if it doesn't exist
        mkdir -p /var/www/html/wp-content/mu-plugins
        chown -R www-data:www-data /var/www/html/wp-content/mu-plugins
        
        echo "Auto-activation script created for plugins."
    fi
}

# Configure OpenID Connect plugin for Authentik
configure_openid_connect() {
    local wp_cli_available=${1:-1}
    echo "Configuring OpenID Connect for Authentik..."
    
    if [ $wp_cli_available -eq 0 ] && command -v wp &> /dev/null; then
        # Set OpenID Connect configuration options using WP-CLI
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
        }' --format=json --allow-root 2>/dev/null
    else
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
        
        mysql -h"${WORDPRESS_DB_HOST%%:*}" -P"${WORDPRESS_DB_HOST##*:}" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" -e "
            INSERT INTO ${WORDPRESS_TABLE_PREFIX:-wp_}options (option_name, option_value) VALUES ('openid_connect_settings', '$config')
            ON DUPLICATE KEY UPDATE option_value = '$config';
        " 2>/dev/null || echo "Warning: Could not configure OpenID Connect via database"
    fi
    
    echo "OpenID Connect configured for Authentik."
}

# Configure WordPress MCP plugin
configure_mcp_plugin() {
    local wp_cli_available=${1:-1}
    echo "Configuring WordPress MCP plugin..."
    
    if [ $wp_cli_available -eq 0 ] && command -v wp &> /dev/null; then
        # Enable MCP endpoints using WP-CLI
        wp option update wordpress_mcp_enabled 1 --allow-root 2>/dev/null
        wp option update wordpress_mcp_api_key "${WORDPRESS_MCP_API_KEY:-demo-api-key-poc}" --allow-root 2>/dev/null
    else
        # Configure via direct database operations
        mysql -h"${WORDPRESS_DB_HOST%%:*}" -P"${WORDPRESS_DB_HOST##*:}" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" -e "
            INSERT INTO ${WORDPRESS_TABLE_PREFIX:-wp_}options (option_name, option_value) VALUES 
                ('wordpress_mcp_enabled', '1'),
                ('wordpress_mcp_api_key', '${WORDPRESS_MCP_API_KEY:-demo-api-key-poc}')
            ON DUPLICATE KEY UPDATE 
                option_value = VALUES(option_value);
        " 2>/dev/null || echo "Warning: Could not configure MCP plugin via database"
    fi
    
    echo "WordPress MCP plugin configured."
}

# Create application password for API access
create_application_password() {
    echo "Creating application password for API access..."
    
    local user="${WORDPRESS_ADMIN_USER:-admin}"
    local app_name="MCP Integration"
    
    if command -v wp &> /dev/null; then
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
    else
        echo "Application passwords require WP-CLI. Will be created manually if needed."
    fi
}

# Update permalink structure
update_permalinks() {
    local wp_cli_available=${1:-1}
    echo "Updating permalink structure..."
    
    if [ $wp_cli_available -eq 0 ] && command -v wp &> /dev/null; then
        wp rewrite structure '/%postname%/' --allow-root 2>/dev/null
        wp rewrite flush --allow-root 2>/dev/null
    else
        # Update via database - already set in the main options insert
        echo "Permalink structure set via database options."
    fi
    
    echo "Permalinks updated."
}

# Main initialization function
main() {
    echo "Starting WordPress initialization..."
    
    # Change to WordPress directory
    cd /var/www/html
    
    # Install WP-CLI
    install_wp_cli
    local wp_cli_available=$?
    
    # Install plugins
    install_plugins
    
    # Wait for database
    wait_for_db
    
    # Install WordPress if needed
    install_wordpress
    
    # Check if WP-CLI is working after potential removal due to failure
    if command -v wp &> /dev/null && wp --info &> /dev/null; then
        wp_cli_available=0
    else
        wp_cli_available=1
    fi
    
    # Activate plugins
    activate_plugins
    
    # Configure plugins (pass wp_cli_available status)
    configure_openid_connect $wp_cli_available
    configure_mcp_plugin $wp_cli_available
    
    # Create application password (only if WP-CLI works)
    if [ $wp_cli_available -eq 0 ]; then
        create_application_password
    else
        echo "Application passwords require WP-CLI. Skipping."
    fi
    
    # Update permalinks
    update_permalinks $wp_cli_available
    
    echo "WordPress initialization completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi