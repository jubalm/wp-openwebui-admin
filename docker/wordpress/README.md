# Custom WordPress Docker Image

This directory contains the configuration for building a custom WordPress Docker image that eliminates manual setup and provides a fully automated deployment experience.

## Overview

The custom WordPress image extends the official WordPress base image with:

- **Pre-installed plugins**: WordPress MCP and OpenID Connect Generic
- **Automated setup**: Bypasses WordPress installation wizard
- **Configuration management**: Environment variable-driven configuration
- **SSO integration**: Ready for Authentik OAuth integration
- **API access**: Pre-configured application passwords and MCP API keys

## Files

### `Dockerfile`
- Extends `wordpress:6.4-apache`
- Installs WP-CLI for automated management
- Downloads and installs required plugins
- Sets up custom entrypoint and initialization scripts

### `wp-config-custom.php`
- Custom WordPress configuration template
- Enables environment variable-driven setup
- Configures local development settings
- Sets up security keys and authentication options

### `init-wordpress.sh`
- WordPress initialization script
- Performs automated WordPress installation
- Activates and configures plugins
- Creates admin user and API credentials
- Configures SSO and MCP settings

### `docker-entrypoint-custom.sh`
- Custom Docker entrypoint
- Chains with original WordPress entrypoint
- Triggers automated initialization after startup

## Environment Variables

### Core WordPress Configuration
```bash
WORDPRESS_DB_HOST=mysql:3306          # Database host
WORDPRESS_DB_USER=wordpress           # Database user
WORDPRESS_DB_PASSWORD=password        # Database password
WORDPRESS_DB_NAME=wordpress           # Database name
```

### Automated Setup Configuration
```bash
WORDPRESS_URL=http://localhost:8080   # Site URL
WORDPRESS_TITLE="Site Title"          # Site title
WORDPRESS_ADMIN_USER=admin            # Admin username
WORDPRESS_ADMIN_PASS=admin            # Admin password
WORDPRESS_ADMIN_EMAIL=admin@example.com # Admin email
```

### Plugin Configuration
```bash
WORDPRESS_MCP_API_KEY=demo-api-key-poc # MCP API key
```

### Security Keys
```bash
WORDPRESS_AUTH_KEY=unique-key          # Authentication key
WORDPRESS_SECURE_AUTH_KEY=unique-key   # Secure auth key
WORDPRESS_LOGGED_IN_KEY=unique-key     # Logged in key
WORDPRESS_NONCE_KEY=unique-key         # Nonce key
WORDPRESS_AUTH_SALT=unique-salt        # Auth salt
WORDPRESS_SECURE_AUTH_SALT=unique-salt # Secure auth salt
WORDPRESS_LOGGED_IN_SALT=unique-salt   # Logged in salt
WORDPRESS_NONCE_SALT=unique-salt       # Nonce salt
```

## Building the Image

### Manual Build
```bash
# Build with default tag
./scripts/build-wordpress.sh

# Build with custom tag
./scripts/build-wordpress.sh v1.0.0
```

### Docker Compose Build
```bash
# Build as part of docker-compose stack
docker-compose up --build

# Force rebuild
docker-compose build wordpress
```

## Features

### 🚀 Zero Manual Configuration
- No WordPress setup wizard
- No plugin installation required
- No admin user creation needed
- No SSO configuration steps

### 🔧 Environment-Driven Setup
- All configuration via environment variables
- Easy multi-instance deployment
- CI/CD friendly
- Kubernetes ready

### 🔌 Pre-Installed Plugins
- **WordPress MCP Plugin v0.2.2**: Official Automattic MCP server
- **OpenID Connect Generic**: SSO integration with Authentik

### 🔐 Security Ready
- Application passwords enabled
- Unique security keys support
- Local development optimizations
- Production security patterns

### 📊 Production Features
- Automated health checks
- Plugin activation validation
- Database connection verification
- Error logging and debugging

## Deployment Patterns

### Single Instance
Perfect for development and testing:
```yaml
services:
  wordpress:
    build: ./docker/wordpress
    environment:
      WORDPRESS_ADMIN_USER: admin
      WORDPRESS_ADMIN_PASS: secure-password
```

### Multi-Instance
Scale to multiple WordPress instances:
```yaml
services:
  wordpress-site1:
    build: ./docker/wordpress
    environment:
      WORDPRESS_URL: http://site1.local
      WORDPRESS_TITLE: "Site 1"
  
  wordpress-site2:
    build: ./docker/wordpress
    environment:
      WORDPRESS_URL: http://site2.local
      WORDPRESS_TITLE: "Site 2"
```

### CI/CD Integration
Automated deployment pipeline ready:
```bash
# Build and test
docker build -t wordpress-custom:${BUILD_NUMBER} ./docker/wordpress
docker run --rm wordpress-custom:${BUILD_NUMBER} wp --version

# Deploy
docker tag wordpress-custom:${BUILD_NUMBER} registry/wordpress-custom:latest
docker push registry/wordpress-custom:latest
```

## Troubleshooting

### Plugin Installation Issues
If plugins fail to install during build:
```bash
# Check Dockerfile RUN commands
docker build --no-cache ./docker/wordpress

# Verify plugin downloads
docker run --rm wordpress-custom ls -la /var/www/html/wp-content/plugins/
```

### Initialization Script Issues
If WordPress setup fails:
```bash
# Check initialization logs
docker logs wp-instance | grep init-wordpress

# Run initialization manually
docker exec wp-instance /usr/local/bin/init-wordpress.sh
```

### Environment Variable Issues
If configuration doesn't apply:
```bash
# Check environment variables
docker exec wp-instance env | grep WORDPRESS

# Verify wp-config.php
docker exec wp-instance cat /var/www/html/wp-config.php
```

### Database Connection Issues
If WordPress can't connect to database:
```bash
# Test database connectivity
docker exec wp-instance mysql -h mysql -u wordpress -p

# Check database readiness
docker logs mysql
```

## Best Practices

### Security
- Use unique security keys in production
- Change default admin credentials
- Enable HTTPS in production environments
- Use environment files for sensitive data

### Performance
- Use specific WordPress version tags
- Optimize Docker layer caching
- Pre-build images for faster deployment
- Use multi-stage builds for production

### Maintenance
- Regular plugin updates via new image builds
- Monitor initialization script execution
- Log analysis for troubleshooting
- Health check implementation

## Integration with OpenWebUI

The custom WordPress image is designed to work seamlessly with OpenWebUI:

1. **MCP Protocol**: WordPress MCP plugin provides standardized AI integration
2. **API Access**: Automated API key generation for OpenWebUI access
3. **SSO Ready**: OpenID Connect plugin configured for Authentik integration
4. **CORS Handling**: Proper headers for cross-origin requests

## Future Enhancements

- [ ] Multi-site support for WordPress networks
- [ ] Plugin marketplace integration
- [ ] Automated SSL certificate management
- [ ] Database migration tools
- [ ] Backup and restore capabilities
- [ ] Performance monitoring integration