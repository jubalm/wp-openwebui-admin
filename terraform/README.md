# Terraform Modules for Multi-Tenant WordPress + OpenWebUI Platform

This directory contains Terraform modules for automating the provisioning of tenant infrastructure on IONOS Cloud for the simplified multi-tenant WordPress and OpenWebUI platform.

## Architecture Overview

The simplified PoC architecture includes:

- **Single OpenWebUI instance** shared across all tenants with user-level isolation
- **WordPress per tenant** deployed in separate Kubernetes namespaces  
- **Authentik SSO** for unified authentication across WordPress and OpenWebUI
- **IONOS MariaDB** managed database cluster for persistent storage
- **IONOS LoadBalancers** for external access to tenant WordPress instances

## Module Structure

```
terraform/
├── modules/
│   ├── infrastructure/       # Shared infrastructure (MariaDB cluster)
│   ├── mariadb-cluster/      # IONOS MariaDB cluster resource
│   ├── tenant-namespace/     # Kubernetes namespace with basic RBAC
│   ├── tenant-database/      # MariaDB database and user creation
│   ├── tenant-wordpress/     # WordPress deployment with MCP plugin
│   └── tenant/              # Main orchestrating module
└── examples/
    ├── infrastructure/      # Infrastructure deployment example
    └── single-tenant/       # Example tenant configuration
```

## Modules

### infrastructure
Provisions shared infrastructure components:
- Creates IONOS MariaDB cluster for all tenants
- Configurable cluster sizing and maintenance windows
- Outputs connection details for tenant modules

### mariadb-cluster
Creates the actual IONOS MariaDB cluster resource:
- `ionoscloud_mariadb_cluster` resource
- Network security configuration
- Maintenance window settings
- Admin credentials management

### tenant-namespace
Creates an isolated Kubernetes namespace for a tenant's WordPress instance with:
- ServiceAccount and basic RBAC permissions
- Optional ResourceQuota for resource management
- Proper labeling for tenant identification

### tenant-database  
Sets up database resources for a tenant within the IONOS MariaDB cluster:
- Creates isolated database for tenant WordPress
- Creates database user with appropriate permissions
- Generates secure credentials and stores in Kubernetes secret

### tenant-wordpress
Deploys WordPress for a tenant with:
- WordPress container with MCP plugin support
- Authentik SSO integration configuration
- IONOS LoadBalancer for external access
- Persistent storage for WordPress files
- Auto-generated WordPress authentication keys

### tenant (Main Module)
Orchestrates all components for a complete tenant deployment:
- Coordinates namespace, database, and WordPress modules
- Manages dependencies between components
- Provides unified configuration interface

## Usage

### Prerequisites

1. **IONOS Cloud account** with API token access
2. **IONOS Managed Kubernetes cluster** set up and accessible
3. **Terraform** installed with required providers
4. **kubectl** configured for your IONOS Kubernetes cluster

### Deployment Process

The deployment follows a two-step process:

#### Step 1: Deploy Infrastructure
First, deploy the shared infrastructure (MariaDB cluster):

```bash
cd terraform/examples/infrastructure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your IONOS Cloud credentials and configuration
terraform init
terraform plan
terraform apply
```

#### Step 2: Deploy Tenants
Then deploy individual tenants using the MariaDB cluster from step 1:

```bash
cd terraform/examples/single-tenant
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with MariaDB connection details from step 1
terraform init
terraform plan
terraform apply
```

### Configuration

#### Infrastructure Variables
For the infrastructure deployment:
- `ionos_token` - Your IONOS Cloud API token
- `datacenter_id` - IONOS datacenter ID where resources will be created
- `lan_id` - LAN ID for the MariaDB cluster
- `mariadb_admin_user/password` - Admin credentials for MariaDB cluster
- `cluster_name` - Display name for the MariaDB cluster
- `location` - Geographic location (e.g., "de/fra")

#### Tenant Variables
For tenant deployments:
- `mariadb_host` - MariaDB cluster hostname (from infrastructure outputs)
- `mariadb_admin_user/password` - Admin credentials for MariaDB
- `authentik_issuer_url` - Your Authentik SSO instance URL
- `authentik_client_secret` - OIDC client secret for WordPress integration

## Key Features

### Simplified for PoC
- Minimal complexity suitable for demonstration
- Basic isolation using Kubernetes namespaces
- HTTP access (no TLS complexity for demo)
- Manual tenant setup process

### IONOS Cloud Integration
- **Managed Kubernetes**: Uses IONOS Managed Kubernetes service
- **LoadBalancers**: Automatic IONOS LoadBalancer provisioning
- **MariaDB**: Fully managed IONOS MariaDB cluster with automated provisioning
- **Storage**: Uses IONOS CSI driver for persistent volumes
- **Infrastructure as Code**: Complete infrastructure provisioning via Terraform

### Security
- Namespace-based tenant isolation
- Auto-generated secure database credentials
- WordPress authentication keys/salts generation
- Authentik SSO integration for unified authentication

## Next Steps After Deployment

1. **Access WordPress**: Use the LoadBalancer IP provided in outputs
2. **Configure Authentik**: Set up OIDC client with the WordPress redirect URI
3. **Install MCP Plugin**: Complete WordPress setup and install MCP plugin
4. **OpenWebUI Integration**: Configure WordPress to integrate with the shared OpenWebUI instance

## Troubleshooting

### Common Issues

1. **LoadBalancer IP not assigned**: Check IONOS LoadBalancer quota and limits
2. **Database connection issues**: Verify MariaDB cluster accessibility and credentials
3. **Pod startup failures**: Check resource quotas and storage class availability

### Debug Commands

```bash
# Check pod status
kubectl get pods -n tenant-<tenant-id>

# View pod logs
kubectl logs -n tenant-<tenant-id> deployment/wordpress

# Check services and LoadBalancer
kubectl get svc -n tenant-<tenant-id>

# Verify database secret
kubectl get secret database-credentials -n tenant-<tenant-id> -o yaml
```

## Cost Optimization

This simplified approach is cost-effective for PoC:
- Single OpenWebUI instance reduces compute costs
- Shared MariaDB cluster with per-tenant databases
- Namespace-based isolation avoids separate cluster costs
- Basic resource quotas prevent resource sprawl

## Scaling Considerations

For production scaling beyond the PoC:
- Consider dedicated OpenWebUI instances for larger tenants
- Implement automated tenant provisioning workflows
- Add network policies for enhanced security
- Set up monitoring and alerting for all tenants