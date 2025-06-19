# Tenant Module

This is the main Terraform module that orchestrates all tenant infrastructure components. It combines the namespace, networking, storage, and security modules to provide complete tenant isolation and infrastructure provisioning for the multi-tenant WordPress and OpenWebUI platform.

## Features

- **Complete Tenant Infrastructure**: Single module to provision all tenant resources
- **Modular Architecture**: Combines specialized sub-modules for different infrastructure aspects
- **IONOS Cloud Optimized**: Designed specifically for IONOS Managed Kubernetes
- **Parameterizable**: Extensive configuration options for different tenant requirements
- **Security-First**: Implements comprehensive security controls by default
- **Production-Ready**: Suitable for production deployments with proper resource management

## Usage

### Basic Usage

```hcl
module "my_tenant" {
  source = "./modules/tenant"
  
  # Required parameters
  tenant_id             = "acme-corp"
  wp_admin_email        = "admin@acme-corp.com"
  openwebui_admin_email = "admin@acme-corp.com"
  
  # Optional: Custom configuration
  environment = "production"
  base_domain = "acme-corp.com"
}
```

### Advanced Configuration

```hcl
module "enterprise_tenant" {
  source = "./modules/tenant"
  
  # Tenant identification
  tenant_id     = "enterprise-client"
  namespace_name = "enterprise-client-prod"
  environment   = "production"
  
  # Domain configuration
  base_domain      = "enterprise-client.com"
  wordpress_domain = "blog.enterprise-client.com"
  openwebui_domain = "ai.enterprise-client.com"
  
  # Admin credentials
  wp_admin_email        = "admin@enterprise-client.com"
  openwebui_admin_email = "ai-admin@enterprise-client.com"
  
  # Resource allocation (large tenant)
  cpu_requests    = "4"
  memory_requests = "8Gi"
  cpu_limits      = "8"
  memory_limits   = "16Gi"
  
  # Storage configuration
  storage_class_name                = "ionos-csi-ssd"
  wordpress_db_storage_size         = "100Gi"
  wordpress_content_storage_size    = "50Gi"
  openwebui_storage_size           = "25Gi"
  
  # Security configuration
  pod_security_standard = "restricted"
  enable_tls           = true
  cert_manager_issuer  = "letsencrypt-prod"
  
  # Enhanced security
  enable_security_scanning     = true
  scan_medium_vulnerabilities  = true
  enable_audit_logging        = true
  
  # Backup configuration
  enable_backup_config  = true
  backup_schedule       = "0 */6 * * *"  # Every 6 hours
  backup_retention_days = 90
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| kubernetes | ~> 2.20 |
| random | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| kubernetes | ~> 2.20 |
| random | ~> 3.1 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| namespace | ../tenant-namespace | Kubernetes namespace with RBAC and isolation |
| storage | ../tenant-storage | Persistent volumes and database credentials |
| security | ../tenant-security | Security policies, secrets, and TLS |
| networking | ../tenant-networking | LoadBalancers and networking configuration |

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Tenant Module                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │
│  │   Namespace     │  │   Networking    │  │    Storage      │     │
│  │   Module        │  │   Module        │  │    Module       │     │
│  │                 │  │                 │  │                 │     │
│  │ • Namespace     │  │ • LoadBalancers │  │ • PVCs          │     │
│  │ • RBAC          │  │ • Services      │  │ • Secrets       │     │
│  │ • NetworkPolicy │  │ • DNS Config    │  │ • Storage Class │     │
│  │ • Quotas        │  │ • External IPs  │  │ • Backup Config │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘     │
│                                                                     │
│  ┌─────────────────┐                                               │
│  │   Security      │     ┌─────────────────────────────────────┐   │
│  │   Module        │────▶│        Complete Tenant             │   │
│  │                 │     │        Infrastructure              │   │
│  │ • Pod Security  │     │                                     │   │
│  │ • Secrets Mgmt  │     │ • Isolated Namespace                │   │
│  │ • TLS Certs     │     │ • IONOS LoadBalancers              │   │
│  │ • Scanning      │     │ • Persistent Storage                │   │
│  └─────────────────┘     │ • Security Controls                 │   │
│                          │ • Monitoring & Logging              │   │
│                          └─────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Infrastructure Components

### Namespace Resources
- **Kubernetes Namespace**: Isolated environment for tenant resources
- **ServiceAccount**: For tenant application pods
- **RBAC**: Role and RoleBinding with minimal permissions
- **NetworkPolicies**: Traffic isolation between tenants
- **ResourceQuota**: CPU, memory, and resource limits
- **LimitRange**: Default resource constraints for containers

### Networking Resources
- **LoadBalancer Services**: IONOS LoadBalancers for WordPress and OpenWebUI
- **Internal Services**: ClusterIP services for inter-service communication
- **Network Policies**: External access control
- **DNS Configuration**: Domain mapping and internal FQDNs

### Storage Resources
- **Persistent Volume Claims**: For WordPress database, content, and OpenWebUI data
- **Storage Classes**: IONOS CSI integration (SSD/HDD)
- **Database Credentials**: Auto-generated secure credentials
- **Backup Configuration**: Automated backup scheduling

### Security Resources
- **Pod Security Standards**: Enforced security policies
- **Application Secrets**: WordPress keys/salts, OpenWebUI JWT secrets
- **TLS Certificates**: cert-manager integration for HTTPS
- **Security Scanning**: Vulnerability scanning configuration
- **Monitoring**: Prometheus metrics and audit logging

## Inputs

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| tenant_id | Unique identifier for the tenant | `string` |
| wp_admin_email | WordPress admin email | `string` |
| openwebui_admin_email | OpenWebUI admin email | `string` |

### Core Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| namespace_name | Kubernetes namespace name | `string` | `"{tenant_id}-ns"` |
| environment | Environment type | `string` | `"dev"` |
| base_domain | Base domain for services | `string` | `"example.com"` |
| wordpress_domain | Custom WordPress domain | `string` | `null` |
| openwebui_domain | Custom OpenWebUI domain | `string` | `null` |

### Resource Allocation

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cpu_requests | Total CPU requests | `string` | `"2"` |
| memory_requests | Total memory requests | `string` | `"4Gi"` |
| cpu_limits | Total CPU limits | `string` | `"4"` |
| memory_limits | Total memory limits | `string` | `"8Gi"` |

### Storage Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| storage_class_name | Storage class name | `string` | `"ionos-csi-ssd"` |
| wordpress_db_storage_size | WordPress database storage | `string` | `"20Gi"` |
| wordpress_content_storage_size | WordPress content storage | `string` | `"10Gi"` |
| openwebui_storage_size | OpenWebUI data storage | `string` | `"5Gi"` |

### Security Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| pod_security_standard | Pod Security Standard level | `string` | `"restricted"` |
| enable_tls | Enable TLS certificates | `bool` | `true` |
| enable_security_scanning | Enable vulnerability scanning | `bool` | `true` |
| enable_audit_logging | Enable audit logging | `bool` | `true` |

For complete variable documentation, see [variables.tf](variables.tf).

## Outputs

### Summary Outputs

| Name | Description |
|------|-------------|
| tenant_summary | Complete tenant infrastructure summary |
| access_info | Access URLs and credentials |
| namespace_name | Created namespace name |

### Component Outputs

| Name | Description |
|------|-------------|
| storage | Storage-related outputs (PVCs, credentials, sizes) |
| security | Security-related outputs (secrets, certificates, config) |
| networking | Networking outputs (IPs, domains, services) |

### Sensitive Outputs

| Name | Description |
|------|-------------|
| database_credentials | Database passwords (sensitive) |
| application_credentials | Application admin passwords (sensitive) |

## Tenant Sizing Guidelines

### Small Tenant (1-10 users)
```hcl
cpu_requests    = "500m"
memory_requests = "1Gi"
cpu_limits      = "1"
memory_limits   = "2Gi"

wordpress_db_storage_size      = "10Gi"
wordpress_content_storage_size = "5Gi"
openwebui_storage_size        = "2Gi"
```

### Medium Tenant (10-100 users)
```hcl
cpu_requests    = "1"
memory_requests = "2Gi"
cpu_limits      = "2"
memory_limits   = "4Gi"

wordpress_db_storage_size      = "20Gi"
wordpress_content_storage_size = "10Gi"
openwebui_storage_size        = "5Gi"
```

### Large Tenant (100+ users)
```hcl
cpu_requests    = "2"
memory_requests = "4Gi"
cpu_limits      = "4"
memory_limits   = "8Gi"

wordpress_db_storage_size      = "50Gi"
wordpress_content_storage_size = "25Gi"
openwebui_storage_size        = "15Gi"
```

### Enterprise Tenant (500+ users)
```hcl
cpu_requests    = "4"
memory_requests = "8Gi"
cpu_limits      = "8"
memory_limits   = "16Gi"

wordpress_db_storage_size      = "100Gi"
wordpress_content_storage_size = "50Gi"
openwebui_storage_size        = "25Gi"
```

## Security Profiles

### Development Security
```hcl
pod_security_standard = "baseline"
enable_tls           = false
enable_security_scanning = false
log_level           = "DEBUG"
```

### Production Security
```hcl
pod_security_standard = "restricted"
enable_tls           = true
cert_manager_issuer  = "letsencrypt-prod"
enable_security_scanning = true
enable_audit_logging = true
log_level           = "INFO"
```

### Enterprise Security
```hcl
pod_security_standard = "restricted"
enable_tls           = true
cert_manager_issuer  = "company-ca-issuer"
enable_security_scanning = true
security_scan_schedule = "0 */6 * * *"
scan_medium_vulnerabilities = true
scan_low_vulnerabilities = true
enable_audit_logging = true
log_level           = "DEBUG"
```

## Deployment Patterns

### Single Tenant

```hcl
module "single_tenant" {
  source = "./modules/tenant"
  
  tenant_id             = "main-tenant"
  wp_admin_email        = "admin@company.com"
  openwebui_admin_email = "admin@company.com"
}
```

### Multi-Tenant

```hcl
# Small tenant
module "tenant_small" {
  source = "./modules/tenant"
  
  tenant_id = "small-client"
  # ... small tenant configuration
}

# Large tenant  
module "tenant_large" {
  source = "./modules/tenant"
  
  tenant_id = "large-client"
  # ... large tenant configuration
}
```

### Environment-Based

```hcl
# Development
module "dev_tenant" {
  source = "./modules/tenant"
  
  tenant_id   = "dev-environment"
  environment = "development"
  # ... development configuration
}

# Production
module "prod_tenant" {
  source = "./modules/tenant"
  
  tenant_id   = "prod-environment"
  environment = "production"
  # ... production configuration
}
```

## Examples

See the [examples directory](../../examples/) for complete usage examples:

- **[Single Tenant](../../examples/single-tenant/)**: Complete example with multiple tenants
- **Development Setup**: Minimal configuration for testing
- **Production Setup**: Enterprise-grade configuration

## Troubleshooting

### Common Issues

1. **Module Dependencies**:
   ```bash
   terraform init
   terraform plan
   ```

2. **Resource Conflicts**:
   ```bash
   kubectl get all -n <namespace>
   terraform state list
   ```

3. **Storage Issues**:
   ```bash
   kubectl get pvc -n <namespace>
   kubectl describe pvc <pvc-name> -n <namespace>
   ```

4. **Networking Issues**:
   ```bash
   kubectl get svc -n <namespace>
   kubectl get networkpolicies -n <namespace>
   ```

### Debug Commands

```bash
# Check all tenant resources
kubectl get all -n <tenant-namespace>

# Check module outputs
terraform output tenant_summary
terraform output access_info

# Verify security configuration
kubectl get configmaps -n <namespace> | grep security
kubectl get secrets -n <namespace>

# Check certificates
kubectl get certificates -n <namespace>
```

## Monitoring

### Resource Monitoring
```bash
# Check resource usage
kubectl top pods -n <namespace>
kubectl top nodes

# Check quotas
kubectl describe resourcequota -n <namespace>
```

### Application Monitoring
```bash
# Check service status
kubectl get svc -n <namespace>
curl -I http://<loadbalancer-ip>

# Check logs
kubectl logs -f deployment/<app-name> -n <namespace>
```

## Cost Management

### Resource Optimization
- Monitor actual vs requested resources
- Adjust resource quotas based on usage
- Use appropriate storage classes (SSD vs HDD)
- Implement resource cleanup policies

### Cost Tracking
- Use tenant labels for cost allocation
- Monitor LoadBalancer costs
- Track storage usage and growth
- Implement automated scaling policies

## Best Practices

### Security
1. Always use `restricted` Pod Security Standard for production
2. Enable TLS for all external access
3. Regular security scanning and updates
4. Implement proper backup and disaster recovery

### Performance
1. Right-size resources based on actual usage
2. Use SSD storage for databases and applications
3. Monitor and tune resource quotas
4. Implement horizontal pod autoscaling

### Operations
1. Use consistent naming conventions
2. Document tenant-specific configurations
3. Implement automated monitoring and alerting
4. Regular backup verification

### Development
1. Use separate environments for development and production
2. Test changes in development environment first
3. Use infrastructure as code for all changes
4. Implement proper CI/CD pipelines

## Integration

This module works with:
- **Helm Charts**: For application deployment
- **cert-manager**: For TLS certificate management
- **Prometheus**: For monitoring and metrics
- **Backup Solutions**: For data protection
- **CI/CD Pipelines**: For automated deployment

## Roadmap

Future enhancements planned:
- [ ] Horizontal Pod Autoscaler integration
- [ ] Advanced monitoring and alerting
- [ ] Multi-cluster support
- [ ] Automated backup and restore
- [ ] Cost optimization recommendations
- [ ] Integration with IONOS Cloud services (DNS, CDN)