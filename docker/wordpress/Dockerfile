FROM wordpress:6.4-apache

# Install required system packages
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    default-mysql-client \
    curl \
    less \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create plugins directory
RUN mkdir -p /var/www/html/wp-content/plugins

# Copy initialization script for later use
COPY init-wordpress.sh /usr/local/bin/init-wordpress.sh
RUN chmod +x /usr/local/bin/init-wordpress.sh

# Set ownership for pre-installed plugins
RUN chown -R www-data:www-data /var/www/html

# Use the standard WordPress entrypoint
# No custom entrypoint - let WordPress handle everything normally