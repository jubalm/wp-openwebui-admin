# WordPress Docker Image

This directory contains a custom WordPress Docker image that provides fully automated WordPress installation using environment variables.

## Features

- **Zero Configuration**: WordPress installation is completely automated
- **Pre-installed Plugins**: Includes WordPress MCP and OpenID Connect Generic plugins
- **Environment-Driven Setup**: All configuration via environment variables
- **No Setup Wizard**: Bypasses WordPress installation screens

## Key Environment Variables

The Docker image uses `SITE_*` environment variables for WordPress installation:

- `SITE_URL`: WordPress site URL (default: `http://localhost:8080`)
- `SITE_TITLE`: Site title (default: `WordPress MCP Admin`)
- `SITE_ADMIN_USER`: Admin username (default: `admin`)
- `SITE_ADMIN_PASSWORD`: Admin password (default: `admin123`) 
- `SITE_ADMIN_EMAIL`: Admin email (default: `admin@localhost`)

## Architecture

The image uses a multi-stage build:

1. **Build Stage** (`php:8.2-cli`): Downloads plugins and tools
2. **Runtime Stage** (`wordpress:php8.2-fpm`): Final WordPress image

## Files

- `Dockerfile`: Multi-stage Docker build definition
- `wp-entrypoint.sh`: Custom entrypoint that handles automated setup
- `README.md`: This documentation file

## Usage

When the container starts, the entrypoint script:

1. Waits for database connectivity
2. Checks if WordPress is already installed
3. If not installed, runs `wp core install` with provided environment variables
4. Activates pre-installed plugins automatically
5. Starts WordPress normally

This eliminates the need for manual WordPress setup and ensures consistent deployment across environments.