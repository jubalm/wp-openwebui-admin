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

# Function to initialize WordPress after files are ready
post_copy_initialization() {
    echo "Running post-copy WordPress initialization..."
    
    cd /var/www/html
    
    # Check if already initialized
    if is_wordpress_installed; then
        echo "WordPress already initialized, skipping setup."
        return 0
    fi
    
    # Setup our custom wp-config
    if [ ! -f "/var/www/html/wp-config.php" ]; then
        echo "Creating wp-config.php with custom settings..."
        cp /usr/src/wordpress/wp-config-custom.php /var/www/html/wp-config.php
        
        # Update wp-config.php with database settings
        sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
        sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php  
        sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
        sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
    fi
    
    # Wait for database
    wait_for_database
    
    # Run the full WordPress initialization
    /usr/local/bin/init-wordpress.sh
    
    echo "Post-copy initialization completed!"
}

# Main execution logic
if [[ "$1" == apache2* ]] || [[ "$1" == php-fpm* ]]; then
    echo "Starting WordPress container with automated setup..."
    
    # Start the original WordPress entrypoint in background to let it copy files
    echo "Starting WordPress file setup..."
    /usr/local/bin/docker-entrypoint.sh "$@" &
    WP_PID=$!
    
    # Wait for WordPress files to be copied
    echo "Waiting for WordPress files to be ready..."
    attempts=0
    while [ ! -f "/var/www/html/index.php" ] && [ $attempts -lt 30 ]; do
        sleep 2
        ((attempts++))
    done
    
    if [ -f "/var/www/html/index.php" ]; then
        echo "WordPress files are ready, running initialization..."
        # Run our initialization now that files are copied
        post_copy_initialization &
        INIT_PID=$!
        
        # Wait for initialization to complete
        wait $INIT_PID
        echo "WordPress initialization completed, web server ready!"
    else
        echo "WordPress files not ready after waiting, continuing anyway..."
    fi
    
    # Wait for the original WordPress process
    wait $WP_PID
else
    # For non-web server commands, just run them directly
    exec /usr/local/bin/docker-entrypoint.sh "$@"
fi