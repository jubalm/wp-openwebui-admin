# Terraform Modules for Multi-Tenant WordPress & OpenWebUI Platform

This directory contains Terraform modules for automating the provisioning of tenant infrastructure on IONOS Cloud. The modules implement the namespace-based isolation strategy for the multi-tenant WordPress and OpenWebUI platform.

## 🏗️ Architecture Overview

The infrastructure is organized into modular components that work together to provide complete tenant isolation:

```
┌─────────────────────────────────────────────────────────────────────┐
│                           IONOS Managed Kubernetes                   │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │
│  │   Tenant-001    │  │   Tenant-002    │  │   Tenant-XXX    │     │
│  │   Namespace     │  │   Namespace     │  │   Namespace     │     │
│  │                 │  │                 │  │                 │     │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────┐ │     │
│  │ │ WordPress   │ │  │ │ WordPress   │ │  │ │ WordPress   │ │     │
│  │ │ + MCP       │ │  │ │ + MCP       │ │  │ │ + MCP       │ │     │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ └─────────────┘ │     │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────┐ │     │
│  │ │ OpenWebUI   │ │  │ │ OpenWebUI   │ │  │ │ OpenWebUI   │ │     │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ └─────────────┘ │     │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────┐ │     │
│  │ │ MySQL DB    │ │  │ │ MySQL DB    │ │  │ │ MySQL DB    │ │     │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ └─────────────┘ │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘     │
└─────────────────────────────────────────────────────────────────────┘
            │                        │                        │
            ▼                        ▼                        ▼
    ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
    │ IONOS LoadBalancer │    │ IONOS LoadBalancer │    │ IONOS LoadBalancer │
    │ WordPress: 80/443 │    │ WordPress: 80/443 │    │ WordPress: 80/443 │
    │ OpenWebUI: 80/443 │    │ OpenWebUI: 80/443 │    │ OpenWebUI: 80/443 │
    └─────────────────┘      └─────────────────┘      └─────────────────┘
```

## 📁 Module Structure

```
terraform/
├── modules/
│   ├── tenant-namespace/     # Kubernetes namespace with RBAC and isolation
│   ├── tenant-networking/    # LoadBalancers and networking configuration
│   ├── tenant-storage/       # Persistent volumes and database credentials
│   ├── tenant-security/      # Security policies, secrets, and TLS
│   └── tenant/              # Main module orchestrating all components
├── examples/
│   └── single-tenant/       # Example configuration for provisioning tenants
└── README.md               # This file
```

## 🎯 Key Features

### Tenant Isolation
- **Kubernetes Namespaces**: Each tenant gets an isolated namespace
- **RBAC**: Role-based access control with minimal permissions
- **Network Policies**: Strict ingress/egress rules for network isolation
- **Resource Quotas**: CPU, memory, and storage limits per tenant

### IONOS Cloud Integration
- **Managed Kubernetes**: Leverages IONOS Managed Kubernetes service
- **LoadBalancers**: Automatic IONOS LoadBalancer provisioning for external access
- **CSI Storage**: Integration with IONOS CSI driver for persistent volumes
- **Security**: Pod Security Standards and security scanning

### Infrastructure as Code
- **Modular Design**: Reusable modules for different infrastructure components
- **Parameterizable**: Tenant-specific configurations through variables
- **Automated**: Complete infrastructure provisioning with single command
- **Scalable**: Easy to provision multiple tenants with different resource profiles

## 🚀 Quick Start

### Prerequisites

1. **IONOS Cloud Account**: With access to Managed Kubernetes
2. **Kubernetes Cluster**: Running IONOS Managed Kubernetes cluster
3. **Terraform**: Version 1.0 or later
4. **kubectl**: Configured to access your cluster

### Basic Usage

1. **Navigate to Example**:
   ```bash
   cd terraform/examples/single-tenant
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Customize Configuration**:
   Edit `main.tf` to configure your tenant details:
   ```hcl
   module "my_tenant" {
     source = "../../modules/tenant"
     
     tenant_id             = "my-company"
     wp_admin_email        = "admin@my-company.com"
     openwebui_admin_email = "admin@my-company.com"
     
     # Domain configuration
     base_domain      = "my-company.com"
     wordpress_domain = "wp.my-company.com"
     openwebui_domain = "ai.my-company.com"
     
     # Resource allocation
     cpu_requests    = "2"
     memory_requests = "4Gi"
     cpu_limits      = "4"
     memory_limits   = "8Gi"
   }
   ```

4. **Deploy Infrastructure**:
   ```bash
   terraform plan
   terraform apply
   ```

5. **Get Access Information**:
   ```bash
   terraform output deployment_summary
   ```

## 📚 Module Documentation

### Core Modules

- **[tenant-namespace](modules/tenant-namespace/README.md)**: Kubernetes namespace with RBAC and isolation
- **[tenant-networking](modules/tenant-networking/)**: LoadBalancers and networking configuration  
- **[tenant-storage](modules/tenant-storage/)**: Persistent volumes and database credentials
- **[tenant-security](modules/tenant-security/)**: Security policies, secrets, and TLS
- **[tenant](modules/tenant/)**: Main orchestrating module

### Examples

- **[single-tenant](examples/single-tenant/README.md)**: Complete example for provisioning tenants

## 🔧 Configuration

### Tenant Resources

Each tenant can be configured with different resource profiles:

```hcl
# Small tenant (1-10 users)
cpu_requests    = "500m"
memory_requests = "1Gi"
cpu_limits      = "1"
memory_limits   = "2Gi"

# Medium tenant (10-100 users)
cpu_requests    = "1"
memory_requests = "2Gi"
cpu_limits      = "2"
memory_limits   = "4Gi"

# Large tenant (100+ users)
cpu_requests    = "2"
memory_requests = "4Gi"
cpu_limits      = "4"
memory_limits   = "8Gi"
```

### Storage Configuration

Storage is configured per tenant with IONOS CSI:

```hcl
# Production storage
storage_class_name                = "ionos-csi-ssd"
wordpress_db_storage_size         = "20Gi"
wordpress_content_storage_size    = "10Gi"
openwebui_storage_size           = "5Gi"

# Development storage  
storage_class_name                = "ionos-csi-hdd"
wordpress_db_storage_size         = "10Gi"
wordpress_content_storage_size    = "5Gi"
openwebui_storage_size           = "2Gi"
```

### Security Configuration

Security is configured with multiple layers:

```hcl
# Restrictive security (recommended)
pod_security_standard = "restricted"
enable_tls           = true
enable_security_scanning = true
enable_audit_logging = true

# Development security
pod_security_standard = "baseline"
enable_tls           = false
enable_security_scanning = false
enable_audit_logging = false
```

## 🛡️ Security Features

### Multi-Layer Security
- **Pod Security Standards**: Enforces security policies at pod level
- **Network Policies**: Controls traffic between namespaces and external networks
- **RBAC**: Granular permissions for service accounts
- **Secret Management**: Automatic generation and secure storage of secrets
- **TLS Certificates**: Automatic certificate management with cert-manager

### Compliance
- **Audit Logging**: Comprehensive logging for security events
- **Vulnerability Scanning**: Regular security scans of container images
- **Resource Quotas**: Prevents resource exhaustion attacks
- **Network Isolation**: Strict network boundaries between tenants

## 💰 Cost Optimization

### Resource Efficiency
- **Right-sizing**: Appropriate resource requests and limits per tenant
- **Storage Tiers**: Use SSD for performance, HDD for backups
- **Shared Infrastructure**: Multiple tenants on same Kubernetes cluster
- **Auto-scaling**: Horizontal Pod Autoscaler for dynamic scaling

### Monitoring
- **Resource Usage**: Track actual vs requested resources
- **Cost Allocation**: Per-tenant cost tracking with labels
- **Optimization**: Recommendations for resource adjustments

## 🔍 Monitoring & Observability

### Built-in Monitoring
- **Prometheus Integration**: Metrics collection and alerting
- **Resource Monitoring**: CPU, memory, storage usage per tenant
- **Health Checks**: Application and infrastructure health monitoring
- **Log Aggregation**: Centralized logging with tenant isolation

### Alerting
- **Resource Alerts**: Notify when quotas are exceeded
- **Security Alerts**: Detect security policy violations
- **Application Alerts**: Monitor application health and performance

## 🚨 Troubleshooting

### Common Issues

1. **Storage Class Not Found**:
   ```bash
   kubectl get storageclass
   # Ensure IONOS CSI storage classes are available
   ```

2. **LoadBalancer Pending**:
   ```bash
   kubectl get svc -A
   # Check IONOS Cloud Console for LoadBalancer status
   ```

3. **Network Policy Blocking Traffic**:
   ```bash
   kubectl get networkpolicies -A
   # Review and adjust network policies
   ```

### Debug Commands

```bash
# Check tenant resources
kubectl get all -n <tenant-namespace>

# Check resource quotas
kubectl describe resourcequota -n <tenant-namespace>

# Check network policies
kubectl get networkpolicies -n <tenant-namespace>

# Check storage
kubectl get pvc -n <tenant-namespace>
```

## 🛠️ Development & Testing

### Testing Modules

```bash
# Validate Terraform configuration
terraform validate

# Plan deployment
terraform plan

# Apply with auto-approve for testing
terraform apply -auto-approve

# Destroy test resources
terraform destroy -auto-approve
```

### Module Development

When developing new modules:

1. Follow the established naming conventions
2. Include comprehensive variable validation
3. Provide detailed outputs
4. Write clear documentation
5. Include examples

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:

1. Check the [troubleshooting section](#-troubleshooting)
2. Review module documentation
3. Open an issue in the repository
4. Contact the IONOS Cloud support team

## 🔄 Roadmap

- [ ] Helm chart integration for application deployment
- [ ] Multi-cluster support for enhanced isolation
- [ ] Automated backup and disaster recovery
- [ ] Advanced monitoring and alerting
- [ ] Cost optimization recommendations
- [ ] Integration with IONOS Cloud services (DNS, CDN, etc.)