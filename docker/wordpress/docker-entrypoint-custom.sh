#!/bin/bash
set -euo pipefail

# Function to run custom WordPress initialization
custom_init() {
    echo "Starting custom WordPress initialization..."
    
    # Wait for Apache to start and WordPress to be accessible
    sleep 15
    
    # Run our initialization script
    /usr/local/bin/init-wordpress.sh
    
    echo "Custom initialization completed."
}

# Check if we're running Apache
if [[ "$1" == apache2* ]] || [[ "$1" == php-fpm* ]]; then
    # Start custom initialization in background after a delay
    (
        sleep 30  # Give WordPress time to fully start
        custom_init
    ) &
    
    echo "Custom WordPress initialization scheduled."
fi

# Execute the original WordPress entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"