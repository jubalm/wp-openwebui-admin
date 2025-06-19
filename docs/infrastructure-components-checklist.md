# Infrastructure Components Checklist

## Required Infrastructure Components for Single Tenant

Based on the simplified tenant isolation strategy, here are the infrastructure elements needed per tenant:

### Per-Tenant Resources

#### Kubernetes Resources
- [ ] Kubernetes namespace for tenant WordPress instance
- [ ] ServiceAccount for WordPress deployment
- [ ] Basic RBAC (Role/RoleBinding) for namespace access
- [ ] ResourceQuota for resource limits (optional for PoC)

#### Networking Resources
- [ ] IONOS LoadBalancer for external access to WordPress
- [ ] Kubernetes Service (ClusterIP) for internal WordPress access
- [ ] DNS configuration (if using domains, otherwise IP-based access)

#### Storage Resources
- [ ] IONOS MariaDB database within managed cluster
- [ ] Database user and credentials for tenant
- [ ] Persistent Volume Claim for WordPress file uploads
- [ ] Kubernetes Secret for database credentials

#### WordPress Configuration
- [ ] WordPress container deployment with MCP plugin
- [ ] WordPress configuration (wp-config.php secrets)
- [ ] Authentik OIDC/SAML integration configuration

### Shared Resources (One-time setup)

#### Core Platform
- [ ] IONOS Managed Kubernetes cluster
- [ ] IONOS MariaDB managed database cluster
- [ ] Single OpenWebUI deployment
- [ ] Authentik SSO deployment

#### OpenWebUI Configuration
- [ ] OpenWebUI database setup (in shared MariaDB)
- [ ] Authentik integration for OpenWebUI
- [ ] User management configuration

#### Authentik SSO Setup
- [ ] Authentik application configuration for OpenWebUI
- [ ] Authentik application configuration template for WordPress instances
- [ ] User and group management setup

### Credentials and Secrets Management

#### Per-Tenant Secrets
- [ ] MariaDB database credentials
- [ ] WordPress authentication keys/salts
- [ ] Authentik OIDC client credentials for WordPress

#### Shared Secrets
- [ ] OpenWebUI database credentials
- [ ] Authentik admin and system credentials
- [ ] Inter-service communication secrets

### IONOS Cloud Resources

#### Compute and Orchestration
- [ ] IONOS Managed Kubernetes cluster
- [ ] Node pools with appropriate sizing

#### Database
- [ ] IONOS MariaDB managed database cluster
- [ ] Database sizing appropriate for multi-tenant use
- [ ] Backup configuration (managed service feature)

#### Networking
- [ ] LoadBalancer IPs for external access
- [ ] Security groups/firewall rules (basic HTTP access)
- [ ] VPC configuration (if required)

#### Storage
- [ ] Storage classes for persistent volumes
- [ ] Backup storage (if implementing backup strategy)

## Implementation Priority

### Phase 1: Core Infrastructure
1. IONOS Managed Kubernetes cluster
2. IONOS MariaDB managed database cluster
3. Basic networking (LoadBalancers)

### Phase 2: Platform Services
1. Authentik SSO deployment
2. OpenWebUI deployment
3. Database setup and configuration

### Phase 3: Tenant Infrastructure
1. Terraform modules for tenant resources
2. WordPress deployment automation
3. Authentik integration per tenant

## Terraform Module Structure Planning

Based on this checklist, the Terraform modules should be organized as:

```
terraform/
├── modules/
│   ├── shared-platform/     # Core platform (K8s, MariaDB, Authentik, OpenWebUI)
│   ├── tenant-namespace/    # K8s namespace with basic RBAC
│   ├── tenant-database/     # MariaDB database and user
│   ├── tenant-wordpress/    # WordPress deployment resources
│   └── tenant/             # Main tenant orchestration module
└── examples/
    └── single-tenant/      # Example tenant configuration
```

This structure aligns with the simplified PoC approach and avoids the complexity of the previous implementation.