# Helm Chart Deployment Guide

This guide explains how to deploy the multi-tenant WordPress and OpenWebUI platform using Helm charts.

## Prerequisites

- Kubernetes cluster (1.24+)
- Helm 3.8+
- kubectl configured to access your cluster
- Persistent Volume support
- Ingress Controller (optional, for external access)

## Architecture Overview

The platform consists of three main components:

1. **Shared Services** - Centralized infrastructure (Authentik SSO, databases)
2. **WordPress Tenants** - Individual WordPress instances with MCP plugin
3. **OpenWebUI** - Shared UI for all tenants

### Database Options

Each WordPress tenant can use one of three database configurations:

1. **IONOS Hosted MariaDB** (Recommended for production)
   - Fully managed database service
   - Automated backups and maintenance
   - SSL/TLS encryption
   - High availability and scalability

2. **External Database** (Custom database servers)
   - Connect to any MySQL/MariaDB server
   - Optional SSL/TLS support
   - Custom connection parameters

3. **Internal MariaDB** (Development/testing)
   - Kubernetes StatefulSet deployment
   - Persistent volume storage
   - Suitable for development environments

## Quick Start

### 1. Deploy Shared Services (One-time setup)

```bash
# Create shared services namespace
kubectl create namespace shared-services

# Deploy shared services
helm install shared-services ./charts/shared-services \
  --namespace shared-services \
  -f values/examples/shared-services.yaml
```

### 2. Deploy a Tenant

Choose one of the following deployment examples based on your database preference:

#### Option A: IONOS Hosted MariaDB (Production)
```bash
# Create tenant namespace
kubectl create namespace tenant-ionos

# Deploy WordPress with IONOS hosted MariaDB
helm install tenant-ionos ./charts/wordpress-tenant \
  --namespace tenant-ionos \
  -f values/examples/tenant-ionos.yaml
```

#### Option B: External Database
```bash
# Create tenant namespace
kubectl create namespace tenant-acme

# Deploy WordPress with external database
helm install tenant-acme ./charts/wordpress-tenant \
  --namespace tenant-acme \
  -f values/examples/tenant-acme.yaml
```

#### Option C: Internal MariaDB (Development)
```bash
# Create tenant namespace
kubectl create namespace tenant-dev

# Deploy WordPress with internal MariaDB
helm install tenant-dev ./charts/wordpress-tenant \
  --namespace tenant-dev \
  -f values/examples/tenant-dev.yaml
```

### 3. Deploy OpenWebUI (Shared instance)

```bash
# Deploy OpenWebUI to shared services
helm install openwebui ./charts/openwebui \
  --namespace shared-services \
  -f values/examples/shared-services.yaml
```

## Development Setup

For local development and testing:

```bash
# Deploy development tenant
helm install tenant-dev ./charts/wordpress-tenant \
  --namespace tenant-dev \
  --create-namespace \
  -f values/examples/tenant-dev.yaml

# Access via port-forward
kubectl port-forward -n tenant-dev svc/tenant-dev-wordpress-tenant 8080:80
```

## Configuration

### Tenant Configuration

Each tenant can be customized via values files:

```yaml
# values/tenant-mycompany.yaml
global:
  tenant: "mycompany"

wordpress:
  site:
    url: "https://mycompany.example.com"
    title: "My Company WordPress"
    adminEmail: "admin@mycompany.com"
  
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
  
  ingress:
    enabled: true
    hosts:
      - host: mycompany.example.com
        paths:
          - path: /
            pathType: Prefix
```

### Database Options

#### Internal Database (Development)
```yaml
database:
  internal:
    enabled: true
    auth:
      database: "wordpress"
      username: "wordpress"
      password: "secure-password"
```

#### External Database (Production)
```yaml
database:
  external:
    enabled: true
    host: "mysql.database.svc.cluster.local"
    port: 3306
    name: "wordpress_prod"
    user: "wp_user"
    password: "secure-password"
```

### Ingress Configuration

#### Standard Ingress
```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: mysite.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: mysite-tls
      hosts:
        - mysite.example.com
```

#### IONOS LoadBalancer
```yaml
loadBalancer:
  enabled: true
  annotations:
    service.beta.kubernetes.io/ionos-loadbalancer-forwarding-rules: |
      - port: 80
        protocol: HTTP
        target_port: 80
  loadBalancerIP: "192.168.1.100"
```

## Database Configuration

The WordPress tenant chart supports multiple database options:

### IONOS Hosted MariaDB

IONOS Database-as-a-Service provides a fully managed MariaDB solution with automated backups, maintenance, and SSL/TLS encryption.

#### Prerequisites
1. Create a MariaDB cluster in the IONOS console
2. Create a database and user for WordPress
3. Download the SSL CA certificate

#### Configuration
```yaml
database:
  ionos:
    enabled: true
    # Database cluster endpoint from IONOS console
    host: "mariadb-cluster-12345.database.ionos.com"
    port: 3306
    name: "wordpress_tenant"
    user: "wp_user"
    password: "secure-password-from-ionos"
    # SSL configuration (required by IONOS)
    ssl:
      enabled: true
      mode: "require"  # Options: require, verify-ca, verify-full
      # Base64 encoded CA certificate from IONOS
      caCert: |
        LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t
        # IONOS CA certificate content
        LS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ==
    # Connection optimization
    connection:
      timeout: 30
      maxConnections: 20
      charset: "utf8mb4"
      collation: "utf8mb4_unicode_ci"
    # IONOS-specific annotations
    annotations:
      ionos.com/database-cluster: "cluster-name"
      ionos.com/backup-policy: "daily"
```

### External Database

Connect to any external MySQL/MariaDB server:

```yaml
database:
  external:
    enabled: true
    host: "external-db.example.com"
    port: 3306
    name: "wordpress_db"
    user: "wp_user"
    password: "password"
    # Optional SSL configuration
    ssl:
      enabled: true
      mode: "require"
      caCert: "base64-encoded-ca-cert"
```

### Internal MariaDB

Deploy MariaDB as a StatefulSet (development only):

```yaml
database:
  internal:
    enabled: true
    auth:
      database: "wordpress"
      username: "wordpress"
      password: "generated-password"
    primary:
      persistence:
        enabled: true
        size: 8Gi
        storageClass: "standard"
```

### Database Priority

The chart uses the following priority order:
1. IONOS hosted MariaDB (if `database.ionos.enabled: true`)
2. External database (if `database.external.enabled: true`)
3. Internal MariaDB (if `database.internal.enabled: true`)

Only one database option should be enabled at a time.

## Security

### Network Policies

Network policies provide tenant isolation:

```yaml
networkPolicy:
  enabled: true
  allowFromSharedServices: true
  # Custom rules
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: monitoring
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: external-apis
```

### RBAC

Each tenant gets isolated RBAC permissions:

```yaml
rbac:
  create: true
  # Additional permissions if needed
```

### Secrets Management

Secrets are automatically generated or can be provided:

```yaml
wordpress:
  site:
    adminPassword: "custom-password"
  mcp:
    apiKey: "custom-api-key"
  auth:
    oauth:
      clientSecret: "oauth-secret"
```

## Monitoring

### Prometheus Integration

```yaml
monitoring:
  serviceMonitor:
    enabled: true
    interval: 30s
  podAnnotations:
    prometheus.io/scrape: "true"
```

### Health Checks

WordPress health endpoints:
- `/wp-admin/install.php` - WordPress installation status
- `/wp-json/wp/v2/wpmcp/health` - MCP plugin health

OpenWebUI health endpoints:
- `/api/v1/health` - Application health

## Backup and Recovery

### Automated Backups

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2 AM
  retention: "30d"
  storage:
    size: 50Gi
    storageClass: "standard"
```

### Manual Backup

```bash
# Create backup
kubectl exec -n tenant-acme deployment/tenant-acme-wordpress-tenant -- \
  wp db export --path=/var/www/html

# Backup files
kubectl exec -n tenant-acme deployment/tenant-acme-wordpress-tenant -- \
  tar -czf /tmp/wp-content-backup.tar.gz /var/www/html/wp-content
```

## Scaling

### Horizontal Pod Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### Resource Management

```yaml
wordpress:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n tenant-acme
kubectl describe pod <pod-name> -n tenant-acme
```

### View Logs
```bash
kubectl logs -n tenant-acme deployment/tenant-acme-wordpress-tenant
kubectl logs -n tenant-acme deployment/tenant-acme-wordpress-tenant-mariadb
```

### Debug Networking
```bash
# Test connectivity
kubectl exec -n tenant-acme deployment/tenant-acme-wordpress-tenant -- \
  curl -I http://authentik-server.shared-services.svc.cluster.local:9000
```

### Helm Operations
```bash
# Check release status
helm status tenant-acme -n tenant-acme

# Upgrade release
helm upgrade tenant-acme ./charts/wordpress-tenant \
  -n tenant-acme \
  -f values/tenant-acme.yaml

# Rollback release
helm rollback tenant-acme 1 -n tenant-acme
```

## Production Checklist

- [ ] Use external databases for production workloads
- [ ] Enable TLS/SSL certificates
- [ ] Configure proper resource limits
- [ ] Enable monitoring and alerting
- [ ] Set up automated backups
- [ ] Configure network policies
- [ ] Use secure passwords and API keys
- [ ] Test disaster recovery procedures
- [ ] Set up log aggregation
- [ ] Configure autoscaling based on load testing