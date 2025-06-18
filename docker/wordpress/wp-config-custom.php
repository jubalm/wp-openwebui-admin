<?php
/**
 * Custom WordPress configuration for automated deployment
 * This configuration bypasses the setup wizard and enables automated deployment
 */

// Enable local environment for application passwords without SSL
define('WP_ENVIRONMENT_TYPE', 'local');

// Skip setup wizard by setting these values
define('WP_CACHE', false);

// Enable automatic updates for plugins and themes
define('WP_AUTO_UPDATE_CORE', true);

// Enable debug mode for development
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

// Increase memory limit
define('WP_MEMORY_LIMIT', '256M');

// Set maximum upload size
@ini_set('upload_max_size', '64M');
@ini_set('post_max_size', '64M');

// Allow unfiltered uploads for admin users
define('ALLOW_UNFILTERED_UPLOADS', true);

// WordPress database table prefix
$table_prefix = 'wp_';

// Enable plugin activation via environment variables
if (getenv('WORDPRESS_ACTIVATE_PLUGINS')) {
    $active_plugins = explode(',', getenv('WORDPRESS_ACTIVATE_PLUGINS'));
    foreach ($active_plugins as $plugin) {
        if (!empty(trim($plugin))) {
            add_action('init', function() use ($plugin) {
                if (!is_plugin_active($plugin)) {
                    activate_plugin($plugin);
                }
            });
        }
    }
}

// Auto-login configuration for development
if (getenv('WORDPRESS_AUTO_ADMIN_USER') && getenv('WORDPRESS_AUTO_ADMIN_PASS')) {
    define('WORDPRESS_AUTO_ADMIN_USER', getenv('WORDPRESS_AUTO_ADMIN_USER'));
    define('WORDPRESS_AUTO_ADMIN_PASS', getenv('WORDPRESS_AUTO_ADMIN_PASS'));
    define('WORDPRESS_AUTO_ADMIN_EMAIL', getenv('WORDPRESS_AUTO_ADMIN_EMAIL') ?: 'admin@example.com');
}

// Set default site URL and home URL from environment
if (getenv('WORDPRESS_URL')) {
    define('WP_HOME', getenv('WORDPRESS_URL'));
    define('WP_SITEURL', getenv('WORDPRESS_URL'));
}

// Authentication Unique Keys and Salts for security
define('AUTH_KEY',         getenv('WORDPRESS_AUTH_KEY') ?: 'put your unique phrase here');
define('SECURE_AUTH_KEY',  getenv('WORDPRESS_SECURE_AUTH_KEY') ?: 'put your unique phrase here');
define('LOGGED_IN_KEY',    getenv('WORDPRESS_LOGGED_IN_KEY') ?: 'put your unique phrase here');
define('NONCE_KEY',        getenv('WORDPRESS_NONCE_KEY') ?: 'put your unique phrase here');
define('AUTH_SALT',        getenv('WORDPRESS_AUTH_SALT') ?: 'put your unique phrase here');
define('SECURE_AUTH_SALT', getenv('WORDPRESS_SECURE_AUTH_SALT') ?: 'put your unique phrase here');
define('LOGGED_IN_SALT',   getenv('WORDPRESS_LOGGED_IN_SALT') ?: 'put your unique phrase here');
define('NONCE_SALT',       getenv('WORDPRESS_NONCE_SALT') ?: 'put your unique phrase here');

// Absolute path to the WordPress directory
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

// Sets up WordPress vars and included files
require_once ABSPATH . 'wp-settings.php';