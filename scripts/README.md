# Scripts Directory

This directory contains simplified helper scripts for the WordPress and OpenWebUI Integration PoC.

## Available Scripts

### `setup.sh`
**Purpose**: Complete automated setup of the PoC environment

**Usage**:
```bash
./scripts/setup.sh
```

**What it does**:
- Checks for Docker and Docker Compose
- Builds custom WordPress image with pre-installed plugins
- Starts all Docker services (WordPress, OpenWebUI, MariaDB, Authentik)
- Waits for services to be ready
- Provides access URLs and credentials

### `test.sh`
**Purpose**: Comprehensive testing of all PoC components

**Usage**:
```bash
./scripts/test.sh
```

**What it does**:
- Tests WordPress accessibility and REST API
- Validates WordPress CRUD operations (create, read, update, delete posts)
- Tests OpenWebUI accessibility  
- Checks Authentik SSO functionality (if enabled)
- Provides health summary for all services
- Saves detailed logs to `/tmp/poc-test-logs/` for troubleshooting

### `build-wordpress.sh`
**Purpose**: Builds the custom WordPress Docker image

**Usage**:
```bash
./scripts/build-wordpress.sh [tag]
```

**What it does**:
- Builds custom WordPress image with WordPress MCP and OpenID Connect plugins
- Includes automated setup scripts to bypass manual configuration
- Creates production-ready WordPress image for scalable deployment

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
- Cleans up temporary files and logs

## Quick Start

1. **Setup**: `./scripts/setup.sh`
2. **Test**: `./scripts/test.sh`
3. **Cleanup**: `./scripts/cleanup.sh` (when done)

## Access Points

After running setup:
- **WordPress**: http://localhost:8080 (admin/admin123)
- **OpenWebUI**: http://localhost:3000
- **Authentik**: http://localhost:9000 (admin/admin)

## Prerequisites

- Docker and Docker Compose installed
- Bash shell
- curl (for testing)

## Troubleshooting

### Make Scripts Executable
```bash
chmod +x scripts/*.sh
```

### View Service Status
```bash
docker compose ps
```

### View Service Logs
```bash
docker compose logs [service-name]
```

### Test Results
All test logs are saved to `/tmp/poc-test-logs/` for detailed troubleshooting.

## Support

Refer to the main documentation:
- [Setup Guide](../docs/setup-guide.md)
- [Automated SSO Guide](../docs/automated-sso-guide.md)
- [PoC Report](../docs/poc-report.md)