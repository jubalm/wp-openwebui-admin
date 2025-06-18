<?php
/**
 * Custom WordPress configuration for automated deployment
 * This configuration bypasses the setup wizard and enables automated deployment
 */

// MySQL settings - populated by environment variables or placeholders
define('DB_NAME', 'database_name_here');
define('DB_USER', 'username_here');
define('DB_PASSWORD', 'password_here');
define('DB_HOST', 'localhost');

// Database charset and collation
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

// Enable local environment for application passwords without SSL
define('WP_ENVIRONMENT_TYPE', 'local');

// Skip setup wizard by setting these values
define('WP_CACHE', false);

// Enable automatic updates for plugins and themes
define('WP_AUTO_UPDATE_CORE', true);

// Enable debug mode for development
define('WP_DEBUG', getenv('WORDPRESS_DEBUG') ? (bool) getenv('WORDPRESS_DEBUG') : true);
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
$table_prefix = getenv('WORDPRESS_TABLE_PREFIX') ?: 'wp_';

// Set default site URL and home URL from environment
if (getenv('WORDPRESS_URL')) {
    define('WP_HOME', getenv('WORDPRESS_URL'));
    define('WP_SITEURL', getenv('WORDPRESS_URL'));
}

// Force site URL and home URL for automated deployment
$wordpress_url = getenv('WORDPRESS_URL') ?: 'http://localhost:8080';
define('WP_HOME', $wordpress_url);
define('WP_SITEURL', $wordpress_url);

// Disable file editing in WordPress admin
define('DISALLOW_FILE_EDIT', false);

// Enable automatic database repair
define('WP_ALLOW_REPAIR', true);

// Authentication Unique Keys and Salts for security
define('AUTH_KEY',         getenv('WORDPRESS_AUTH_KEY') ?: 'put your unique phrase here');
define('SECURE_AUTH_KEY',  getenv('WORDPRESS_SECURE_AUTH_KEY') ?: 'put your unique phrase here');
define('LOGGED_IN_KEY',    getenv('WORDPRESS_LOGGED_IN_KEY') ?: 'put your unique phrase here');
define('NONCE_KEY',        getenv('WORDPRESS_NONCE_KEY') ?: 'put your unique phrase here');
define('AUTH_SALT',        getenv('WORDPRESS_AUTH_SALT') ?: 'put your unique phrase here');
define('SECURE_AUTH_SALT', getenv('WORDPRESS_SECURE_AUTH_SALT') ?: 'put your unique phrase here');
define('LOGGED_IN_SALT',   getenv('WORDPRESS_LOGGED_IN_SALT') ?: 'put your unique phrase here');
define('NONCE_SALT',       getenv('WORDPRESS_NONCE_SALT') ?: 'put your unique phrase here');

// Additional configuration from environment
if (getenv('WORDPRESS_CONFIG_EXTRA')) {
    eval(getenv('WORDPRESS_CONFIG_EXTRA'));
}

// Absolute path to the WordPress directory
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

// Sets up WordPress vars and included files
require_once ABSPATH . 'wp-settings.php';