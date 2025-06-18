# Scripts Directory

This directory contains helper scripts for the WordPress and OpenWebUI Integration PoC using the official WordPress MCP plugin.

## Available Scripts

### `build-wordpress.sh`
**Purpose**: Builds the custom WordPress Docker image with pre-installed plugins

**Usage**:
```bash
./scripts/build-wordpress.sh [tag]
```

**What it does**:
- Builds a custom WordPress Docker image with WordPress MCP and OpenID Connect plugins pre-installed
- Includes automated setup scripts to bypass manual configuration
- Creates a production-ready WordPress image with SSO integration
- Supports CI/CD deployment and scalable instance creation

### `setup.sh`
**Purpose**: Automated setup of the entire PoC environment with official WordPress MCP plugin

**Usage**:
```bash
./scripts/setup.sh
```

**What it does**:
- Checks for Docker and Docker Compose
- Validates WordPress MCP plugin installation
- Creates necessary directories
- Starts Docker containers
- Waits for services to be ready
- Provides setup instructions for WordPress MCP configuration

### `test-integration.sh`
**Purpose**: Tests the WordPress MCP integration using WordPress REST API and MCP endpoints

**Usage**:
```bash
./scripts/test-integration.sh
```

**What it does**:
- Tests WordPress REST API connectivity
- Tests WordPress post CRUD operations using automated admin credentials
- Validates MCP endpoint accessibility
- Creates, reads, updates, and deletes test posts
- Reports comprehensive test results

**Prerequisites**: 
- WordPress fully automated setup (no manual configuration needed)
- Uses default admin credentials from docker-compose environment

### `test-sso.sh`
**Purpose**: Validates SSO integration with Authentik for WordPress and OpenWebUI

**Usage**:
```bash
./scripts/test-sso.sh
```

**What it does**:
- Tests Authentik server availability
- Validates OAuth endpoints
- Checks WordPress and OpenWebUI accessibility
- Reports SSO environment status
- Provides manual configuration guidance

### `cleanup.sh`
**Purpose**: Cleans up the PoC environment

**Usage**:
```bash
./scripts/cleanup.sh
```

**What it does**:
- Stops all Docker containers
- Optionally removes volumes and data
- Optionally removes unused Docker images
- Cleans up temporary files

## Usage Order

1. **Build Custom Image**: `./scripts/build-wordpress.sh` (optional, docker-compose will build automatically)
2. **Initial Setup**: `./scripts/setup.sh`
3. **Test Integration**: `./scripts/test-integration.sh`
4. **Test SSO**: `./scripts/test-sso.sh`
5. **Cleanup**: `./scripts/cleanup.sh` (when done)

## Prerequisites

- Docker and Docker Compose installed
- Bash shell
- curl (for testing scripts)
- Executable permissions set on scripts

## Setting Permissions

If scripts are not executable:
```bash
chmod +x scripts/*.sh
```

## Troubleshooting

### Script Permission Denied
```bash
chmod +x scripts/script-name.sh
```

### Docker Not Found
Install Docker and Docker Compose first:
- [Docker Installation](https://docs.docker.com/get-docker/)
- [Docker Compose Installation](https://docs.docker.com/compose/install/)

### Services Not Starting
Check Docker logs:
```bash
docker-compose logs
```

### API Tests Failing
Ensure:
1. WordPress is accessible at http://localhost:8080
2. MCP plugin is activated in WordPress admin
3. WordPress permalinks are set to "Post name"

## Support

Refer to the main documentation:
- [Setup Guide](../docs/setup-guide.md)
- [PoC Report](../docs/poc-report.md)