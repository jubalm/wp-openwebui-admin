# Scripts Directory

This directory contains helper scripts for the WordPress and OpenWebUI Integration PoC using the official WordPress MCP plugin.

## Available Scripts

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
- Tests WordPress post CRUD operations
- Validates MCP endpoint accessibility
- Creates, reads, updates, and deletes test posts
- Reports comprehensive test results

**Prerequisites**: 
- WordPress must be set up and WordPress MCP plugin activated
- Authentication configured (JWT tokens or Application Passwords)
- Update script variables with authentication credentials

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

1. **Initial Setup**: `./scripts/setup.sh`
2. **Manual Configuration**: Complete WordPress setup in browser
3. **Test Integration**: `./scripts/test-integration.sh`
4. **Cleanup**: `./scripts/cleanup.sh` (when done)

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