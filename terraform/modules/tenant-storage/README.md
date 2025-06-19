# Tenant Storage Module

This Terraform module creates persistent storage resources for WordPress and OpenWebUI applications, including database storage, content storage, and backup configuration. It provides IONOS CSI integration for high-performance storage.

## Features

- **Persistent Volume Claims**: Separate storage for WordPress database, content, and OpenWebUI data
- **IONOS CSI Integration**: Native IONOS Cloud storage with SSD and HDD options
- **Database Credentials**: Automatic generation and secure storage of MySQL credentials
- **Custom Storage Classes**: Optional tenant-specific storage classes
- **Backup Configuration**: Configurable backup scheduling and retention
- **Storage Optimization**: Different storage types for different workloads

## Usage

```hcl
module "tenant_storage" {
  source = "./modules/tenant-storage"

  tenant_id      = "tenant-001"
  namespace_name = "tenant-001-ns"
  
  # Storage configuration
  storage_class_name                = "ionos-csi-ssd"
  wordpress_db_storage_size         = "20Gi"
  wordpress_content_storage_size    = "10Gi"
  openwebui_storage_size           = "5Gi"
  
  # Database configuration
  mysql_database = "wordpress"
  mysql_user     = "wordpress"
  
  # Optional: Custom passwords (will be auto-generated if not provided)
  mysql_root_password = "secure-root-password"
  mysql_password      = "secure-user-password"
  
  # Backup configuration
  enable_backup_config  = true
  backup_schedule       = "0 2 * * *"  # Daily at 2 AM
  backup_retention_days = 30
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

## Resources

| Name | Type |
|------|------|
| kubernetes_storage_class.tenant_storage | resource |
| kubernetes_persistent_volume_claim.wordpress_db | resource |
| kubernetes_persistent_volume_claim.wordpress_content | resource |
| kubernetes_persistent_volume_claim.openwebui_data | resource |
| kubernetes_secret.database_credentials | resource |
| kubernetes_config_map.database_config | resource |
| kubernetes_config_map.backup_config | resource |
| random_password.mysql_root | resource |
| random_password.mysql_user | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tenant_id | Unique identifier for the tenant | `string` | n/a | yes |
| namespace_name | Name of the Kubernetes namespace | `string` | n/a | yes |
| storage_class_name | Name of the storage class to use | `string` | `"ionos-csi-ssd"` | no |
| create_custom_storage_class | Create a custom storage class | `bool` | `false` | no |
| storage_provisioner | Storage provisioner for custom storage class | `string` | `"csi.ionos.com"` | no |
| storage_parameters | Parameters for the storage class | `map(string)` | `{"csi.storage.k8s.io/fstype" = "ext4", "type" = "SSD"}` | no |
| wordpress_db_storage_size | Storage size for WordPress database | `string` | `"20Gi"` | no |
| wordpress_content_storage_size | Storage size for WordPress content | `string` | `"10Gi"` | no |
| openwebui_storage_size | Storage size for OpenWebUI data | `string` | `"5Gi"` | no |
| mysql_database | MySQL database name | `string` | `"wordpress"` | no |
| mysql_user | MySQL user for WordPress | `string` | `"wordpress"` | no |
| mysql_root_password | MySQL root password (auto-generated if null) | `string` | `null` | no |
| mysql_password | MySQL user password (auto-generated if null) | `string` | `null` | no |
| enable_backup_config | Enable backup configuration | `bool` | `true` | no |
| backup_schedule | Cron schedule for backups | `string` | `"0 2 * * *"` | no |
| backup_retention_days | Number of days to retain backups | `number` | `30` | no |
| backup_storage_class | Storage class for backups | `string` | `"ionos-csi-hdd"` | no |

## Outputs

| Name | Description |
|------|-------------|
| wordpress_db_pvc_name | Name of the WordPress database PVC |
| wordpress_content_pvc_name | Name of the WordPress content PVC |
| openwebui_data_pvc_name | Name of the OpenWebUI data PVC |
| database_credentials_secret_name | Name of the database credentials secret |
| database_config_name | Name of the database configuration ConfigMap |
| backup_config_name | Name of the backup configuration ConfigMap |
| storage_class_name | Name of the storage class used |
| mysql_database | MySQL database name |
| mysql_user | MySQL user name |
| mysql_host | MySQL host name |
| mysql_root_password | MySQL root password (sensitive) |
| mysql_password | MySQL user password (sensitive) |
| storage_sizes | Storage sizes allocated for the tenant |

## Storage Architecture

### Volume Layout

```
┌─────────────────────────────────────────────────────────────┐
│                    Tenant Namespace                         │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  │ WordPress DB    │  │ WordPress       │  │ OpenWebUI       │
│  │ PVC             │  │ Content PVC     │  │ Data PVC        │
│  │                 │  │                 │  │                 │
│  │ Size: 20Gi      │  │ Size: 10Gi      │  │ Size: 5Gi       │
│  │ Type: SSD       │  │ Type: SSD       │  │ Type: SSD       │
│  │ Access: RWO     │  │ Access: RWM     │  │ Access: RWO     │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘
│           │                     │                     │
│           ▼                     ▼                     ▼
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  │ MySQL Pod       │  │ WordPress Pod   │  │ OpenWebUI Pod   │
│  │ /var/lib/mysql  │  │ /var/www/html   │  │ /app/data       │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
                    ┌─────────────────┐
                    │ IONOS Cloud     │
                    │ Block Storage   │
                    │                 │
                    │ • SSD/HDD Types │
                    │ • Automatic     │
                    │   Provisioning  │
                    │ • Snapshot      │
                    │   Support       │
                    └─────────────────┘
```

### IONOS CSI Integration

The module integrates with IONOS Cloud Storage Infrastructure (CSI) driver:

```hcl
# Storage class configuration
storage_parameters = {
  "csi.storage.k8s.io/fstype" = "ext4"
  "type"                      = "SSD"    # or "HDD"
}
```

Available IONOS storage types:
- **SSD**: High-performance storage for databases and applications
- **HDD**: Cost-effective storage for backups and archives

## Database Configuration

### Credentials Management

The module automatically generates secure database credentials if not provided:

```yaml
# Generated secret: {tenant_id}-db-credentials
data:
  mysql_root_password: <base64-encoded-32-char-password>
  mysql_database: <base64-encoded-database-name>
  mysql_user: <base64-encoded-username>
  mysql_password: <base64-encoded-32-char-password>
```

### Database Configuration

```yaml
# ConfigMap: {tenant_id}-db-config
data:
  mysql_database: "wordpress"
  mysql_user: "wordpress"
  mysql_host: "{tenant_id}-mysql"
  mysql_port: "3306"
```

## Backup Configuration

### Automated Backup Setup

When `enable_backup_config` is true, the module creates backup configuration:

```yaml
# ConfigMap: {tenant_id}-backup-config
data:
  backup_schedule: "0 2 * * *"           # Cron schedule
  backup_retention_days: "30"            # Days to keep backups
  backup_storage_class: "ionos-csi-hdd"  # Storage class for backups
  backup_enabled: "true"
```

### Backup Strategies

1. **Daily Backups**: Default schedule runs at 2 AM daily
2. **Retention Policy**: Configurable retention (default 30 days)
3. **Storage Optimization**: Use HDD storage class for cost-effective backup storage
4. **Multiple Frequencies**: Support for custom cron schedules

## Storage Sizing Guidelines

### Small Tenant (1-10 users)
```hcl
wordpress_db_storage_size      = "10Gi"
wordpress_content_storage_size = "5Gi"
openwebui_storage_size        = "2Gi"
# Total: 17Gi
```

### Medium Tenant (10-100 users)
```hcl
wordpress_db_storage_size      = "20Gi"
wordpress_content_storage_size = "10Gi"
openwebui_storage_size        = "5Gi"
# Total: 35Gi
```

### Large Tenant (100+ users)
```hcl
wordpress_db_storage_size      = "50Gi"
wordpress_content_storage_size = "25Gi"
openwebui_storage_size        = "15Gi"
# Total: 90Gi
```

## Performance Considerations

### Storage Performance

| Storage Type | IOPS | Throughput | Use Case |
|-------------|------|------------|----------|
| SSD | High | High | Database, application data |
| HDD | Medium | Medium | Backups, archives |

### Access Modes

- **ReadWriteOnce (RWO)**: Database and application data
- **ReadWriteMany (RWM)**: WordPress content shared across pods

## Security Features

### Credential Security
- Passwords are auto-generated with 32-character length
- All credentials stored in Kubernetes secrets
- Base64 encoding for secure storage
- No plaintext passwords in Terraform state

### Access Control
- Storage resources are namespace-scoped
- Service accounts have minimal required permissions
- Network policies control access to storage

## Monitoring and Maintenance

### Storage Monitoring

```bash
# Check PVC status
kubectl get pvc -n <namespace>

# Check storage usage
kubectl describe pvc <pvc-name> -n <namespace>

# Monitor storage metrics
kubectl top nodes
kubectl top pods -n <namespace>
```

### Backup Verification

```bash
# Check backup configuration
kubectl get configmap <tenant-id>-backup-config -n <namespace> -o yaml

# Verify backup jobs (if using CronJobs)
kubectl get cronjobs -n <namespace>
```

## Troubleshooting

### Common Issues

1. **PVC Stuck in Pending**:
   ```bash
   kubectl describe pvc <pvc-name> -n <namespace>
   # Check storage class availability
   kubectl get storageclass
   ```

2. **Storage Class Not Found**:
   ```bash
   kubectl get storageclass
   # Verify IONOS CSI driver is installed
   kubectl get pods -n kube-system | grep ionos-csi
   ```

3. **Database Connection Issues**:
   ```bash
   # Check database credentials
   kubectl get secret <tenant-id>-db-credentials -n <namespace> -o yaml
   
   # Verify database configuration
   kubectl get configmap <tenant-id>-db-config -n <namespace> -o yaml
   ```

4. **Storage Full**:
   ```bash
   # Check disk usage in pods
   kubectl exec -it <pod-name> -n <namespace> -- df -h
   
   # Resize PVC (if supported)
   kubectl patch pvc <pvc-name> -n <namespace> -p '{"spec":{"resources":{"requests":{"storage":"50Gi"}}}}'
   ```

## Cost Optimization

### Storage Cost Tips

1. **Use Appropriate Storage Types**:
   - SSD for high-performance workloads
   - HDD for backups and archives

2. **Monitor Storage Usage**:
   ```bash
   kubectl exec -it <pod-name> -n <namespace> -- du -sh /var/lib/mysql
   kubectl exec -it <pod-name> -n <namespace> -- du -sh /var/www/html
   ```

3. **Implement Retention Policies**:
   - Regular cleanup of old backups
   - WordPress media optimization
   - Log rotation and cleanup

4. **Storage Class Selection**:
   ```hcl
   # Production
   storage_class_name = "ionos-csi-ssd"
   
   # Development/Testing
   storage_class_name = "ionos-csi-hdd"
   ```

## Examples

### Development Environment

```hcl
module "dev_storage" {
  source = "./modules/tenant-storage"
  
  tenant_id      = "dev-tenant"
  namespace_name = "dev-tenant-ns"
  
  # Smaller storage for development
  storage_class_name                = "ionos-csi-hdd"
  wordpress_db_storage_size         = "5Gi"
  wordpress_content_storage_size    = "2Gi"
  openwebui_storage_size           = "1Gi"
  
  # Less frequent backups
  backup_schedule       = "0 4 * * 0"  # Weekly
  backup_retention_days = 7
}
```

### Production Environment

```hcl
module "prod_storage" {
  source = "./modules/tenant-storage"
  
  tenant_id      = "prod-tenant"
  namespace_name = "prod-tenant-ns"
  
  # High-performance storage
  storage_class_name                = "ionos-csi-ssd"
  wordpress_db_storage_size         = "100Gi"
  wordpress_content_storage_size    = "50Gi"
  openwebui_storage_size           = "25Gi"
  
  # Frequent backups with long retention
  backup_schedule       = "0 */6 * * *"  # Every 6 hours
  backup_retention_days = 90
  backup_storage_class  = "ionos-csi-hdd"
}
```

## Integration

This module works seamlessly with:
- `tenant-namespace` module for isolated storage resources
- `tenant-security` module for credential management
- Application Helm charts for volume mounting
- Monitoring systems for storage metrics

## Best Practices

1. **Right-size Storage**: Start with appropriate sizes and monitor usage
2. **Use Different Storage Classes**: SSD for performance, HDD for cost savings
3. **Implement Backups**: Always enable backup configuration
4. **Monitor Usage**: Regular monitoring prevents storage exhaustion
5. **Security**: Never store credentials in plain text
6. **Performance**: Use ReadWriteMany only when necessary