# Helm Charts for Multi-Tenant WordPress & OpenWebUI Platform

This directory contains Helm charts for deploying WordPress with MCP plugin and OpenWebUI in a multi-tenant Kubernetes environment.

## Charts Overview

- **`wordpress-tenant/`** - WordPress instance with MCP plugin for individual tenants
- **`openwebui/`** - Shared OpenWebUI instance for all tenants
- **`shared-services/`** - Shared infrastructure services (Authentik SSO, databases)

## Architecture

### Multi-Tenant Design
- Each tenant gets a dedicated namespace: `tenant-<org-name>`
- Shared OpenWebUI instance with tenant user isolation via Authentik SSO
- Tenant-specific WordPress instances with MCP plugin integration
- Centralized authentication and user management

### Database Options
- **Internal MariaDB** - Kubernetes StatefulSet for development/testing
- **External Database** - Connect to any external MySQL/MariaDB server
- **IONOS Hosted MariaDB** - Managed database service with SSL support and automated backups

### Security & Isolation
- Namespace-based tenant isolation
- Network policies for secure inter-service communication
- SSL/TLS support for database connections
- RBAC with tenant-specific permissions
- Secrets management using Kubernetes secrets

## Quick Start

### Deploy Shared Services (One-time setup)
```bash
# Deploy shared services (Authentik, shared OpenWebUI)
helm install shared-services ./charts/shared-services \
  --namespace shared-services \
  --create-namespace \
  -f values/shared-services.yaml
```

### Deploy Tenant Stack
```bash
# Deploy complete tenant stack
helm install tenant-acme ./charts/tenant-stack \
  --namespace tenant-acme \
  --create-namespace \
  -f values/tenant-acme.yaml
```

### Deploy Individual Components
```bash
# Deploy WordPress with IONOS hosted MariaDB
helm install wp-ionos ./charts/wordpress-tenant \
  --namespace tenant-ionos \
  --create-namespace \
  -f values/examples/tenant-ionos.yaml

# Deploy WordPress with internal MariaDB (development)
helm install wp-dev ./charts/wordpress-tenant \
  --namespace tenant-dev \
  --create-namespace \
  -f values/examples/tenant-dev.yaml

# Deploy WordPress with external database
helm install wp-acme ./charts/wordpress-tenant \
  --namespace tenant-acme \
  --create-namespace \
  -f values/examples/tenant-acme.yaml
```

## Database Configuration

The WordPress tenant chart supports three database configurations:

### 1. IONOS Hosted MariaDB (Recommended for Production)
```yaml
database:
  ionos:
    enabled: true
    host: "mariadb-cluster-xxx.database.ionos.com"
    port: 3306
    name: "wordpress_tenant"
    user: "wp_user"
    password: "secure-password"
    ssl:
      enabled: true
      mode: "require"
      caCert: "base64-encoded-ca-certificate"
```

### 2. External Database
```yaml
database:
  external:
    enabled: true
    host: "external-db.example.com"
    port: 3306
    name: "wordpress_db"
    user: "wp_user"
    password: "password"
```

### 3. Internal MariaDB (Development)
```yaml
database:
  internal:
    enabled: true
    auth:
      database: "wordpress"
      username: "wordpress"
      password: "generated-password"
```

## Configuration

All charts are highly configurable via values files. See `values/examples/` directory for examples:

- `values/examples/shared-services.yaml` - Shared infrastructure configuration
- `values/examples/tenant-acme.yaml` - Production tenant with IONOS hosted MariaDB
- `values/examples/tenant-ionos.yaml` - IONOS managed database configuration
- `values/examples/tenant-dev.yaml` - Development configuration with internal MariaDB

## Dependencies

- Kubernetes 1.24+
- Helm 3.8+
- Persistent Volume support
- Ingress Controller (for external access)

## Documentation

- [Chart Development Guide](./docs/development.md)
- [Tenant Onboarding Process](./docs/tenant-onboarding.md)
- [Security Configuration](./docs/security.md)
- [Troubleshooting Guide](./docs/troubleshooting.md)