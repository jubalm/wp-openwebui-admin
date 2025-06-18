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
        
    else
        echo "WordPress is already installed!"
    fi

    echo "WordPress setup complete! Site available at ${SITE_URL:-http://localhost:8080}"
} &

# Run the original WordPress entrypoint
exec docker-entrypoint.sh apache2-foreground
