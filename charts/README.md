# Helm Charts for Multi-Tenant WordPress & OpenWebUI Platform

This directory contains Helm charts for deploying WordPress with MCP plugin and OpenWebUI in a multi-tenant Kubernetes environment.

## Charts Overview

- **`wordpress-tenant/`** - WordPress instance with MCP plugin for individual tenants
- **`openwebui/`** - Shared OpenWebUI instance for all tenants
- **`shared-services/`** - Shared infrastructure services (Authentik SSO, databases)
- **`tenant-stack/`** - Complete tenant deployment (umbrella chart)

## Architecture

### Multi-Tenant Design
- Each tenant gets a dedicated namespace: `tenant-<org-name>`
- Shared OpenWebUI instance with tenant user isolation via Authentik SSO
- Tenant-specific WordPress instances with MCP plugin integration
- Centralized authentication and user management

### Security & Isolation
- Namespace-based tenant isolation
- Network policies for secure inter-service communication
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
# Deploy only WordPress for a tenant
helm install wp-acme ./charts/wordpress-tenant \
  --namespace tenant-acme \
  --create-namespace \
  -f values/wordpress-acme.yaml
```

## Configuration

All charts are highly configurable via values files. See `values/` directory for examples:

- `values/shared-services.yaml` - Shared infrastructure configuration
- `values/tenant-*.yaml` - Tenant-specific configurations
- `values/production/` - Production-ready configurations

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