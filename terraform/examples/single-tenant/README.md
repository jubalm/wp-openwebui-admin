# Single Tenant Example

This example demonstrates how to provision complete infrastructure for one or more tenants using the tenant Terraform modules.

## Prerequisites

Before running this example, ensure you have:

1. **IONOS Managed Kubernetes Cluster**: A running cluster with appropriate node capacity
2. **kubectl configured**: Access to your IONOS Kubernetes cluster
3. **Terraform installed**: Version 1.0 or later
4. **Storage Classes**: IONOS CSI storage classes configured (`ionos-csi-ssd`, `ionos-csi-hdd`)
5. **cert-manager** (optional): For automatic TLS certificate management
6. **DNS Configuration**: Ability to point domains to LoadBalancer IPs

## Quick Start

1. **Clone and Navigate**:
   ```bash
   cd terraform/examples/single-tenant
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the Plan**:
   ```bash
   terraform plan
   ```

4. **Apply Configuration**:
   ```bash
   terraform apply
   ```

5. **Get Access Information**:
   ```bash
   terraform output deployment_summary
   terraform output -json tenant_001_credentials
   ```

## What Gets Created

For each tenant, this example creates:

### Kubernetes Resources
- **Namespace**: Isolated namespace with labels and annotations
- **ServiceAccount**: For tenant applications
- **RBAC**: Role and RoleBinding for namespace-scoped permissions
- **NetworkPolicies**: Ingress/egress rules for network isolation
- **ResourceQuota**: CPU, memory, and resource limits
- **LimitRange**: Default resource constraints for containers

### Storage Resources
- **PersistentVolumeClaims**: For WordPress database, content, and OpenWebUI data
- **StorageClass**: Custom or default IONOS CSI storage class
- **Secrets**: Database credentials (auto-generated)
- **ConfigMaps**: Database and backup configuration

### Networking Resources
- **LoadBalancer Services**: IONOS LoadBalancers for external access
- **Internal Services**: ClusterIP services for inter-service communication
- **NetworkPolicies**: External access rules
- **DNS Configuration**: Domain mapping and internal FQDNs

### Security Resources
- **Pod Security Standards**: Restricted security context
- **Application Secrets**: WordPress keys/salts, OpenWebUI JWT secrets
- **TLS Certificates**: cert-manager integration for HTTPS
- **Security Scanning**: Configuration for vulnerability scanning
- **Monitoring**: Prometheus and logging configuration

## Configuration Options

### Tenant Sizing

The example includes two different tenant configurations:

**Small Tenant (tenant-001)**:
- 1 CPU core, 2GB RAM requests
- 2 CPU cores, 4GB RAM limits  
- 17Gi total storage

**Large Tenant (tenant-002)**:
- 2 CPU cores, 4GB RAM requests
- 4 CPU cores, 8GB RAM limits
- 35Gi total storage

### Customization

Modify the module configuration to suit your needs:

```hcl
module "my_tenant" {
  source = "../../modules/tenant"
  
  tenant_id   = "my-company"
  environment = "production"
  
  # Custom domains
  wordpress_domain = "my-company.example.com"
  openwebui_domain = "ai.my-company.example.com"
  
  # Resource allocation
  cpu_requests    = "4"      # 4 CPU cores
  memory_requests = "8Gi"    # 8GB RAM
  cpu_limits      = "8"      # 8 CPU cores  
  memory_limits   = "16Gi"   # 16GB RAM
  
  # Storage sizes
  wordpress_db_storage_size      = "50Gi"
  wordpress_content_storage_size = "20Gi"
  openwebui_storage_size        = "10Gi"
  
  # Security
  pod_security_standard = "restricted"
  enable_tls           = true
  
  # Admin credentials
  wp_admin_email        = "admin@my-company.com"
  openwebui_admin_email = "admin@my-company.com"
}
```

## Post-Deployment Steps

After successful deployment:

### 1. Configure DNS
Point your domains to the LoadBalancer IPs:
```bash
# Get the IPs
terraform output deployment_summary

# Configure DNS A records
tenant001-wp.example.com    -> <WordPress LoadBalancer IP>
tenant001-ui.example.com    -> <OpenWebUI LoadBalancer IP>
```

### 2. Deploy Applications
Use the provided Helm charts to deploy WordPress and OpenWebUI:
```bash
# Deploy using tenant infrastructure outputs
helm install tenant-001-wordpress ./helm/wordpress \
  --namespace $(terraform output -raw tenant_001_summary | jq -r '.namespace') \
  --set-file values.yaml=<(terraform output -json tenant_001_storage)

helm install tenant-001-openwebui ./helm/openwebui \
  --namespace $(terraform output -raw tenant_001_summary | jq -r '.namespace') \
  --set-file values.yaml=<(terraform output -json tenant_001_networking)
```

### 3. Verify SSL Certificates
Check that cert-manager has issued certificates:
```bash
kubectl get certificates -n $(terraform output -raw tenant_001_summary | jq -r '.namespace')
kubectl describe certificate tenant-001-tls-cert -n <namespace>
```

### 4. Access Applications
- WordPress: Use the WordPress domain and admin credentials
- OpenWebUI: Use the OpenWebUI domain and admin credentials

### 5. Retrieve Credentials
```bash
# Get all credentials in JSON format
terraform output -json tenant_001_credentials

# Get specific password
terraform output -json tenant_001_credentials | jq -r '.applications.wp_admin_password'
```

## Monitoring and Management

### View Resources
```bash
# List all resources in tenant namespace
kubectl get all -n <tenant-namespace>

# Check resource usage
kubectl top pods -n <tenant-namespace>
kubectl describe resourcequota -n <tenant-namespace>
```

### Scaling Resources
Modify the Terraform configuration and apply:
```bash
# Edit main.tf to increase resources
# Then apply changes
terraform apply
```

### Backup Verification
```bash
# Check backup configuration
kubectl get configmap <tenant-id>-backup-config -n <namespace> -o yaml
```

## Troubleshooting

### Common Issues

1. **Storage Class Not Found**:
   ```bash
   kubectl get storageclass
   # Ensure ionos-csi-ssd and ionos-csi-hdd exist
   ```

2. **LoadBalancer Pending**:
   ```bash
   kubectl get svc -n <namespace>
   kubectl describe svc <service-name> -n <namespace>
   # Check IONOS Cloud Console for LoadBalancer status
   ```

3. **Certificate Issues**:
   ```bash
   kubectl get certificaterequests -n <namespace>
   kubectl logs -n cert-manager deployment/cert-manager
   ```

4. **Network Policy Issues**:
   ```bash
   kubectl get networkpolicies -n <namespace>
   # Test connectivity between pods
   ```

### Cleanup

To remove all tenant infrastructure:
```bash
terraform destroy
```

**Warning**: This will permanently delete all tenant data. Ensure backups are in place.

## Security Considerations

- All pods run with restricted security context
- Network policies enforce namespace isolation
- Secrets are auto-generated and stored securely
- TLS certificates are automatically managed
- Resource quotas prevent resource exhaustion
- Security scanning is enabled by default

## Cost Optimization

- Use appropriate resource requests/limits
- Consider HDD storage class for backups
- Monitor actual resource usage and adjust quotas
- Implement pod disruption budgets for availability

## Next Steps

1. Integrate with monitoring (Prometheus/Grafana)
2. Set up automated backups
3. Configure alerting rules
4. Implement GitOps workflow
5. Add disaster recovery procedures