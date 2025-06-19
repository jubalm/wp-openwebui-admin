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

```bash
# Create tenant namespace
kubectl create namespace tenant-acme

# Deploy WordPress for tenant
helm install tenant-acme ./charts/wordpress-tenant \
  --namespace tenant-acme \
  -f values/examples/tenant-acme.yaml
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