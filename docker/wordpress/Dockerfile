FROM wordpress:6.4-apache

# Install required system packages and WP-CLI
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    default-mysql-client \
    curl \
    less \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Note: WP-CLI will be installed in the init script due to network restrictions

# Create plugins directory
RUN mkdir -p /var/www/html/wp-content/plugins

# Download and install WordPress MCP plugin (skipped due to network restrictions)
# Will be handled by init script if not present

# Download and install OpenID Connect Generic plugin (skipped due to network restrictions)  
# Will be handled by init script if not present

# Copy initialization script
COPY init-wordpress.sh /usr/local/bin/init-wordpress.sh
RUN chmod +x /usr/local/bin/init-wordpress.sh

# Copy custom entrypoint script
COPY docker-entrypoint-custom.sh /usr/local/bin/docker-entrypoint-custom.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

# Copy custom wp-config template
COPY wp-config-custom.php /usr/src/wordpress/wp-config-custom.php

# Set ownership for pre-installed plugins
RUN chown -R www-data:www-data /var/www/html

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-custom.sh"]
CMD ["apache2-foreground"]