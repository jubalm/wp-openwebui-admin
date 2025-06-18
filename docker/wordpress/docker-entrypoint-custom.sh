#!/bin/bash
set -euo pipefail

# Function to wait for database
wait_for_database() {
    echo "Waiting for database to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if mysql -h"${WORDPRESS_DB_HOST%%:*}" -P"${WORDPRESS_DB_HOST##*:}" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; then
            echo "Database is ready!"
            return 0
        fi
        echo "Database not ready, waiting... (attempt $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    echo "Database connection failed after $max_attempts attempts"
    return 1
}

# Function to check if WordPress is already installed
is_wordpress_installed() {
    if [ -f "/var/www/html/wp-config.php" ] && mysql -h"${WORDPRESS_DB_HOST%%:*}" -P"${WORDPRESS_DB_HOST##*:}" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -D"$WORDPRESS_DB_NAME" -e "SELECT * FROM ${WORDPRESS_TABLE_PREFIX:-wp_}options WHERE option_name='siteurl' LIMIT 1" >/dev/null 2>&1; then
        echo "WordPress is already installed"
        return 0
    fi
    return 1
}

# Function to setup WordPress configuration
setup_wp_config() {
    echo "Setting up WordPress configuration..."
    
    # Copy our custom wp-config if it doesn't exist
    if [ ! -f "/var/www/html/wp-config.php" ]; then
        echo "Copying custom wp-config.php..."
        cp /usr/src/wordpress/wp-config-custom.php /var/www/html/wp-config.php
        
        # Update wp-config.php with database settings
        sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
        sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php  
        sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
        sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
        
        echo "WordPress configuration completed."
    else
        echo "wp-config.php already exists, skipping setup."
    fi
}

# Function to run complete WordPress initialization
initialize_wordpress() {
    echo "Initializing WordPress..."
    
    # Change to WordPress directory
    cd /var/www/html
    
    # Wait for database
    wait_for_database
    
    # Setup wp-config
    setup_wp_config
    
    # Check if WordPress is already installed
    if is_wordpress_installed; then
        echo "WordPress is already installed, skipping initialization."
        return 0
    fi
    
    # Run our comprehensive initialization script
    echo "Running WordPress installation and configuration..."
    /usr/local/bin/init-wordpress.sh
    
    echo "WordPress initialization completed successfully!"
}

# Main execution logic
if [[ "$1" == apache2* ]] || [[ "$1" == php-fpm* ]]; then
    echo "Starting WordPress container with automated setup..."
    
    # Initialize WordPress completely before starting the web server
    initialize_wordpress
    
    echo "WordPress setup complete. Starting web server..."
fi

# Execute the original WordPress entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"