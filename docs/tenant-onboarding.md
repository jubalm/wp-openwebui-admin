# Tenant Onboarding Process

This guide describes the process for onboarding new tenants to the multi-tenant WordPress & OpenWebUI platform.

## Overview

Each tenant receives:
- Dedicated WordPress instance with MCP plugin
- Isolated Kubernetes namespace
- User accounts in shared OpenWebUI
- Integration with centralized SSO (Authentik)

## Prerequisites

Before onboarding a new tenant, ensure:
- [ ] Shared services are deployed and healthy
- [ ] DNS records are configured (if using custom domains)
- [ ] SSL certificates are available (if using HTTPS)
- [ ] Resource quotas are defined
- [ ] Storage classes are configured

## Onboarding Steps

### 1. Gather Tenant Information

Collect the following information:

```yaml
# Tenant Information Template
tenant_id: "acme"
company_name: "ACME Corporation"
domain: "acme.example.com"
admin_email: "admin@acme.corp"
contact_person: "John Doe <john@acme.corp>"

# Technical Requirements
resource_requirements:
  cpu_limit: "1000m"
  memory_limit: "1Gi"
  storage_size: "20Gi"
  expected_users: 50
  expected_traffic: "low" # low, medium, high

# Features
features:
  mcp_enabled: true
  sso_enabled: true
  backup_enabled: true
  monitoring_enabled: true
```

### 2. Create Tenant Values File

Create a values file for the tenant:

```bash
# Create tenant-specific values file
cat > values/tenant-acme.yaml << EOF
global:
  tenant: "acme"
  sharedServicesNamespace: "shared-services"

wordpress:
  site:
    url: "https://acme.example.com"
    title: "ACME Corporation Portal"
    adminUser: "acme-admin"
    adminEmail: "admin@acme.corp"
  
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi
  
  config:
    environment: "production"
    tablePrefix: "acme_"

ingress:
  enabled: true
  hosts:
    - host: acme.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: acme-tls
      hosts:
        - acme.example.com

# Additional configuration...
EOF
```

### 3. Create Kubernetes Namespace

```bash
# Create namespace for tenant
kubectl create namespace tenant-acme

# Apply resource quotas
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-acme-quota
  namespace: tenant-acme
spec:
  hard:
    requests.cpu: 2000m
    requests.memory: 2Gi
    limits.cpu: 4000m
    limits.memory: 4Gi
    persistentvolumeclaims: 5
    services: 10
    secrets: 20
    configmaps: 20
EOF
```

### 4. Configure DNS (if applicable)

```bash
# Example DNS configuration
# A record: acme.example.com -> LoadBalancer IP
# CNAME record: www.acme.example.com -> acme.example.com
```

### 5. Deploy Tenant WordPress

```bash
# Deploy WordPress for tenant
helm install tenant-acme ./charts/wordpress-tenant \
  --namespace tenant-acme \
  -f values/tenant-acme.yaml \
  --wait \
  --timeout 10m

# Verify deployment
kubectl get pods -n tenant-acme
helm status tenant-acme -n tenant-acme
```

### 6. Configure SSO Integration

```bash
# Create OAuth application in Authentik
kubectl exec -n shared-services deployment/authentik-server -- \
  python manage.py shell << 'EOF'
from authentik.providers.oauth2.models import OAuth2Provider
from authentik.core.models import Application

# Create OAuth provider
provider = OAuth2Provider.objects.create(
    name="WordPress ACME",
    client_id="wordpress-acme",
    client_secret="generated-secret",
    authorization_grant_type="authorization-code",
    client_type="confidential",
    redirect_uris="https://acme.example.com/oauth/callback"
)

# Create application
app = Application.objects.create(
    name="ACME WordPress",
    slug="acme-wordpress",
    provider=provider
)
EOF
```

### 7. Create User Accounts

Create initial user accounts in OpenWebUI:

```bash
# Create tenant admin user in OpenWebUI
kubectl exec -n shared-services deployment/openwebui -- \
  python manage.py create_user \
    --username "acme-admin" \
    --email "admin@acme.corp" \
    --role "tenant-admin" \
    --tenant "acme"

# Create regular users
kubectl exec -n shared-services deployment/openwebui -- \
  python manage.py create_user \
    --username "john.doe" \
    --email "john@acme.corp" \
    --role "user" \
    --tenant "acme"
```

### 8. Configure WordPress Settings

```bash
# Get WordPress admin credentials
ADMIN_PASSWORD=$(kubectl get secret -n tenant-acme tenant-acme-wordpress-tenant \
  -o jsonpath="{.data.admin-password}" | base64 --decode)

echo "WordPress Admin Credentials:"
echo "URL: https://acme.example.com/wp-admin"
echo "Username: acme-admin"
echo "Password: $ADMIN_PASSWORD"

# Get MCP API key
MCP_API_KEY=$(kubectl get secret -n tenant-acme tenant-acme-wordpress-tenant \
  -o jsonpath="{.data.mcp-api-key}" | base64 --decode)

echo "MCP API Key: $MCP_API_KEY"
```

### 9. Test Integration

```bash
# Test WordPress accessibility
curl -I https://acme.example.com

# Test MCP endpoints
curl -H "Authorization: Bearer $MCP_API_KEY" \
  https://acme.example.com/wp-json/wp/v2/wpmcp

# Test SSO integration
curl -I https://acme.example.com/oauth/login
```

### 10. Configure Monitoring

```bash
# Verify monitoring is enabled
kubectl get servicemonitor -n tenant-acme

# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus 9090:9090 &
# Visit http://localhost:9090/targets to verify tenant is monitored
```

## Post-Deployment Tasks

### Documentation

Create tenant-specific documentation:

```bash
# Create tenant documentation directory
mkdir -p docs/tenants/acme

# Document tenant configuration
cat > docs/tenants/acme/README.md << EOF
# ACME Corporation Tenant

## Overview
- Tenant ID: acme
- Domain: acme.example.com
- Namespace: tenant-acme
- Contact: John Doe <john@acme.corp>

## Services
- WordPress: https://acme.example.com
- Admin Panel: https://acme.example.com/wp-admin
- MCP API: https://acme.example.com/wp-json/wp/v2/wpmcp

## Credentials
- WordPress Admin: acme-admin (password in Kubernetes secret)
- MCP API Key: (stored in Kubernetes secret)

## Resources
- CPU: 1000m limit
- Memory: 1Gi limit
- Storage: 20Gi

## Monitoring
- Prometheus: Enabled
- Grafana Dashboard: Available

## Backup
- Schedule: Daily at 2 AM
- Retention: 30 days
EOF
```

### Training Materials

Provide tenant with:
- WordPress admin guide
- MCP plugin documentation
- OpenWebUI user guide
- Support contact information

## Validation Checklist

Use this checklist to validate successful tenant onboarding:

### Infrastructure
- [ ] Namespace created with resource quotas
- [ ] WordPress pod is running and healthy
- [ ] Database is accessible and configured
- [ ] Persistent volumes are mounted
- [ ] Network policies are applied

### Networking
- [ ] Service is accessible within cluster
- [ ] Ingress/LoadBalancer is configured
- [ ] DNS resolution works
- [ ] SSL certificate is valid (if applicable)

### Security
- [ ] RBAC permissions are correctly applied
- [ ] Secrets are properly configured
- [ ] Network policies isolate tenant traffic
- [ ] OAuth integration works

### Integration
- [ ] MCP plugin is active and responding
- [ ] SSO login works
- [ ] OpenWebUI can access WordPress
- [ ] API endpoints are functional

### Monitoring & Backup
- [ ] Prometheus is scraping metrics
- [ ] Grafana dashboard shows data
- [ ] Backup jobs are scheduled
- [ ] Log aggregation is working

## Offboarding Process

When a tenant needs to be removed:

```bash
# 1. Backup tenant data
kubectl exec -n tenant-acme deployment/tenant-acme-wordpress-tenant -- \
  wp db export --path=/var/www/html > tenant-acme-final-backup.sql

# 2. Remove Helm release
helm uninstall tenant-acme -n tenant-acme

# 3. Clean up namespace
kubectl delete namespace tenant-acme

# 4. Remove DNS records
# 5. Revoke SSL certificates
# 6. Remove monitoring configuration
# 7. Clean up documentation
```

## Troubleshooting Common Issues

### WordPress won't start
```bash
# Check pod logs
kubectl logs -n tenant-acme deployment/tenant-acme-wordpress-tenant

# Check database connectivity
kubectl exec -n tenant-acme deployment/tenant-acme-wordpress-tenant -- \
  mysql -h tenant-acme-wordpress-tenant-mariadb -u wordpress -p
```

### SSL/TLS issues
```bash
# Check certificate status
kubectl describe certificate -n tenant-acme acme-tls

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

### SSO not working
```bash
# Check Authentik configuration
kubectl logs -n shared-services deployment/authentik-server

# Verify OAuth configuration
kubectl get secret -n tenant-acme tenant-acme-wordpress-tenant -o yaml
```

## Support

For issues during tenant onboarding:
1. Check the troubleshooting guide above
2. Review Kubernetes events: `kubectl get events -n tenant-acme`
3. Check Helm release status: `helm status tenant-acme -n tenant-acme`
4. Contact platform administrators with tenant ID and error details