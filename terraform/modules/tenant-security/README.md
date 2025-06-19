# Tenant Security Module

This Terraform module implements comprehensive security controls for tenant applications, including Pod Security Standards, secrets management, TLS certificates, and security scanning configuration. It provides enterprise-grade security for WordPress and OpenWebUI deployments.

## Features

- **Pod Security Standards**: Enforces security policies at the pod level
- **Secrets Management**: Automatic generation and secure storage of application secrets
- **TLS Certificates**: Integration with cert-manager for automatic HTTPS
- **Security Scanning**: Configuration for vulnerability scanning
- **WordPress Security**: Complete WordPress authentication keys and salts
- **OpenWebUI Security**: JWT secrets and admin credentials
- **Monitoring Integration**: Security metrics and audit logging

## Usage

```hcl
module "tenant_security" {
  source = "./modules/tenant-security"

  tenant_id      = "tenant-001"
  namespace_name = "tenant-001-ns"
  
  # Admin credentials
  wp_admin_email        = "admin@tenant001.com"
  openwebui_admin_email = "admin@tenant001.com"
  
  # Security configuration
  pod_security_standard = "restricted"
  enable_tls           = true
  cert_manager_issuer  = "letsencrypt-prod"
  
  # Domain configuration for TLS
  base_domain      = "example.com"
  wordpress_domain = "tenant001-wp.example.com"
  
  # Security scanning
  enable_security_scanning = true
  scan_medium_vulnerabilities = true
  
  # Monitoring
  enable_audit_logging = true
  log_level           = "INFO"
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
| kubernetes_config_map.pod_security_config | resource |
| kubernetes_config_map.security_context | resource |
| kubernetes_secret.wordpress_secrets | resource |
| kubernetes_secret.openwebui_secrets | resource |
| kubernetes_secret.tls_certificate | resource |
| kubernetes_config_map.security_scan_config | resource |
| kubernetes_config_map.monitoring_config | resource |
| random_password.wp_* | resource |
| random_password.openwebui_* | resource |

## Security Architecture

### Multi-Layer Security Model

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Security Layers                          │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                  Pod Security Standards                         │ │
│  │  • Restricted security context                                 │ │
│  │  • Non-root containers                                         │ │
│  │  • Read-only root filesystem (where possible)                  │ │
│  │  • Privilege escalation prevention                             │ │
│  │  • Seccomp profiles                                            │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                    Secrets Management                           │ │
│  │  • Auto-generated strong passwords                             │ │
│  │  • WordPress authentication keys & salts                       │ │
│  │  • OpenWebUI JWT secrets                                       │ │
│  │  • Database credentials                                        │ │
│  │  • API keys (optional)                                         │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                  TLS & Certificates                             │ │
│  │  • Automatic certificate generation (cert-manager)             │ │
│  │  • HTTPS enforcement                                            │ │
│  │  • Certificate rotation                                        │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                Security Scanning & Monitoring                   │ │
│  │  • Vulnerability scanning                                      │ │
│  │  • Security policy compliance                                  │ │
│  │  • Audit logging                                               │ │
│  │  • Prometheus metrics                                          │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tenant_id | Unique identifier for the tenant | `string` | n/a | yes |
| namespace_name | Kubernetes namespace name | `string` | n/a | yes |
| pod_security_standard | Pod Security Standard level | `string` | `"restricted"` | no |
| wp_admin_user | WordPress admin username | `string` | `"admin"` | no |
| wp_admin_email | WordPress admin email | `string` | n/a | yes |
| wp_admin_password | WordPress admin password | `string` | `null` | no |
| wp_auth_key | WordPress AUTH_KEY | `string` | `null` | no |
| wp_secure_auth_key | WordPress SECURE_AUTH_KEY | `string` | `null` | no |
| wp_logged_in_key | WordPress LOGGED_IN_KEY | `string` | `null` | no |
| wp_nonce_key | WordPress NONCE_KEY | `string` | `null` | no |
| wp_auth_salt | WordPress AUTH_SALT | `string` | `null` | no |
| wp_secure_auth_salt | WordPress SECURE_AUTH_SALT | `string` | `null` | no |
| wp_logged_in_salt | WordPress LOGGED_IN_SALT | `string` | `null` | no |
| wp_nonce_salt | WordPress NONCE_SALT | `string` | `null` | no |
| openwebui_admin_email | OpenWebUI admin email | `string` | n/a | yes |
| openwebui_admin_password | OpenWebUI admin password | `string` | `null` | no |
| openwebui_jwt_secret | OpenWebUI JWT secret | `string` | `null` | no |
| openai_api_key | OpenAI API key | `string` | `null` | no |
| enable_tls | Enable TLS certificate management | `bool` | `true` | no |
| cert_manager_issuer | Cert-manager issuer name | `string` | `"letsencrypt-prod"` | no |
| base_domain | Base domain for services | `string` | `"example.com"` | no |
| wordpress_domain | Custom WordPress domain | `string` | `null` | no |
| enable_security_scanning | Enable vulnerability scanning | `bool` | `true` | no |
| security_scan_schedule | Cron schedule for security scans | `string` | `"0 3 * * *"` | no |
| scan_medium_vulnerabilities | Include medium severity scans | `bool` | `true` | no |
| scan_low_vulnerabilities | Include low severity scans | `bool` | `false` | no |
| log_level | Application log level | `string` | `"INFO"` | no |
| enable_audit_logging | Enable audit logging | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| wordpress_secrets_name | WordPress secrets name |
| openwebui_secrets_name | OpenWebUI secrets name |
| tls_certificate_name | TLS certificate secret name |
| pod_security_config_name | Pod security configuration name |
| security_context_config_name | Security context configuration name |
| monitoring_config_name | Monitoring configuration name |
| security_scan_config_name | Security scanning configuration name |
| wp_admin_user | WordPress admin username |
| wp_admin_email | WordPress admin email |
| wp_admin_password | WordPress admin password (sensitive) |
| openwebui_admin_email | OpenWebUI admin email |
| openwebui_admin_password | OpenWebUI admin password (sensitive) |
| openwebui_jwt_secret | OpenWebUI JWT secret (sensitive) |
| security_summary | Security configuration summary |

## Pod Security Standards

### Security Context Configuration

The module enforces strict security contexts:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false  # WordPress needs write access
  seccompProfile:
    type: RuntimeDefault
```

### Security Standards Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| `privileged` | Unrestricted (not recommended) | Legacy applications |
| `baseline` | Minimally restrictive | Development |
| `restricted` | Heavily restricted (recommended) | Production |

## Secrets Management

### WordPress Secrets

The module generates all required WordPress authentication keys and salts:

```yaml
# Secret: {tenant_id}-wordpress-secrets
data:
  wp_auth_key: <64-character-random-string>
  wp_secure_auth_key: <64-character-random-string>
  wp_logged_in_key: <64-character-random-string>
  wp_nonce_key: <64-character-random-string>
  wp_auth_salt: <64-character-random-string>
  wp_secure_auth_salt: <64-character-random-string>
  wp_logged_in_salt: <64-character-random-string>
  wp_nonce_salt: <64-character-random-string>
  wp_admin_user: <admin-username>
  wp_admin_password: <16-character-random-password>
  wp_admin_email: <admin-email>
```

### OpenWebUI Secrets

```yaml
# Secret: {tenant_id}-openwebui-secrets
data:
  jwt_secret: <32-character-jwt-secret>
  admin_email: <admin-email>
  admin_password: <16-character-random-password>
  openai_api_key: <api-key-if-provided>
```

### Password Generation

All passwords are automatically generated with:
- **64 characters** for WordPress keys/salts
- **32 characters** for JWT secrets
- **16 characters** for admin passwords
- **Special characters** included for complexity

## TLS Certificate Management

### cert-manager Integration

When `enable_tls` is true, the module creates certificate secrets with cert-manager annotations:

```yaml
# Secret: {tenant_id}-tls-cert
metadata:
  annotations:
    cert-manager.io/issuer: "letsencrypt-prod"
    cert-manager.io/common-name: "tenant001-wp.example.com"
type: kubernetes.io/tls
```

### Certificate Issuers

Supported cert-manager issuers:
- `letsencrypt-staging`: For testing
- `letsencrypt-prod`: For production
- Custom issuers: Organization-specific CAs

## Security Scanning

### Vulnerability Scanning Configuration

```yaml
# ConfigMap: {tenant_id}-security-scan
data:
  scan_schedule: "0 3 * * *"      # Daily at 3 AM
  scan_enabled: "true"
  scan_critical: "true"           # Always scan critical
  scan_high: "true"               # Always scan high
  scan_medium: "true"             # Configurable
  scan_low: "false"               # Usually disabled
```

### Scanning Levels

| Severity | Default | Description |
|----------|---------|-------------|
| Critical | ✅ | Security vulnerabilities requiring immediate attention |
| High | ✅ | Important security issues |
| Medium | ✅ | Moderate security concerns |
| Low | ❌ | Minor issues (can be noisy) |

## Monitoring and Logging

### Monitoring Configuration

```yaml
# ConfigMap: {tenant_id}-monitoring  
data:
  prometheus_scrape: "true"
  metrics_port: "9090"
  log_level: "INFO"
  audit_enabled: "true"
```

### Log Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| DEBUG | Detailed debugging | Development |
| INFO | General information | Production |
| WARN | Warning messages | Production |
| ERROR | Error messages only | Minimal logging |

## Security Best Practices

### Implemented Security Controls

1. **Least Privilege**: Minimal permissions and non-root containers
2. **Defense in Depth**: Multiple security layers
3. **Secure by Default**: Restrictive security policies
4. **Automated Secrets**: No manual password management
5. **Certificate Management**: Automatic TLS certificate handling
6. **Regular Scanning**: Automated vulnerability detection
7. **Audit Logging**: Comprehensive security event logging

### Compliance Features

- **Pod Security Standards**: Kubernetes security baseline compliance
- **Secrets Encryption**: All sensitive data encrypted at rest
- **Network Policies**: Traffic isolation and control
- **Access Logging**: Audit trail for security events
- **Vulnerability Management**: Regular security scanning

## Examples

### Development Environment

```hcl
module "dev_security" {
  source = "./modules/tenant-security"
  
  tenant_id      = "dev-tenant"
  namespace_name = "dev-tenant-ns"
  
  wp_admin_email        = "dev@company.com"
  openwebui_admin_email = "dev@company.com"
  
  # Relaxed security for development
  pod_security_standard = "baseline"
  enable_tls           = false
  enable_security_scanning = false
  log_level           = "DEBUG"
}
```

### Production Environment

```hcl
module "prod_security" {
  source = "./modules/tenant-security"
  
  tenant_id      = "prod-tenant"
  namespace_name = "prod-tenant-ns"
  
  wp_admin_email        = "admin@company.com"
  openwebui_admin_email = "admin@company.com"
  
  # Maximum security for production
  pod_security_standard = "restricted"
  enable_tls           = true
  cert_manager_issuer  = "letsencrypt-prod"
  
  # Custom domains
  wordpress_domain = "blog.company.com"
  
  # Comprehensive scanning
  enable_security_scanning     = true
  scan_medium_vulnerabilities  = true
  scan_low_vulnerabilities     = false
  
  # Enhanced monitoring
  enable_audit_logging = true
  log_level           = "INFO"
  
  # Optional: Provide OpenAI API key
  openai_api_key = var.openai_api_key
}
```

### Enterprise Environment

```hcl
module "enterprise_security" {
  source = "./modules/tenant-security"
  
  tenant_id      = "enterprise-client"
  namespace_name = "enterprise-client-ns"
  
  wp_admin_email        = "admin@client.com"
  openwebui_admin_email = "admin@client.com"
  
  # Enterprise-grade security
  pod_security_standard = "restricted"
  enable_tls           = true
  cert_manager_issuer  = "company-ca-issuer"  # Internal CA
  
  # Custom passwords (if required)
  wp_admin_password         = var.wp_admin_password
  openwebui_admin_password  = var.openwebui_admin_password
  
  # Aggressive scanning
  enable_security_scanning     = true
  security_scan_schedule       = "0 */6 * * *"  # Every 6 hours
  scan_medium_vulnerabilities  = true
  scan_low_vulnerabilities     = true
  
  # Maximum audit logging
  enable_audit_logging = true
  log_level           = "DEBUG"
}
```

## Troubleshooting

### Common Security Issues

1. **Pod Security Policy Violations**:
   ```bash
   kubectl get events -n <namespace> --field-selector reason=FailedCreate
   kubectl describe pod <pod-name> -n <namespace>
   ```

2. **Certificate Issues**:
   ```bash
   kubectl get certificates -n <namespace>
   kubectl describe certificate <cert-name> -n <namespace>
   kubectl logs -n cert-manager deployment/cert-manager
   ```

3. **Secrets Not Found**:
   ```bash
   kubectl get secrets -n <namespace>
   kubectl describe secret <secret-name> -n <namespace>
   ```

4. **Security Scanning Issues**:
   ```bash
   kubectl get configmap <tenant-id>-security-scan -n <namespace> -o yaml
   kubectl logs -n <scanner-namespace> deployment/vulnerability-scanner
   ```

### Debug Commands

```bash
# Check security configurations
kubectl get configmap -n <namespace> | grep security
kubectl get configmap <tenant-id>-pod-security -n <namespace> -o yaml

# Verify secrets
kubectl get secrets -n <namespace>
kubectl describe secret <tenant-id>-wordpress-secrets -n <namespace>

# Check TLS certificates
kubectl get certificates -n <namespace>
kubectl describe certificate <tenant-id>-tls-cert -n <namespace>

# Monitor security events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

## Security Monitoring

### Metrics and Alerts

Set up monitoring for:
- Failed authentication attempts
- Certificate expiration warnings
- Security policy violations
- Vulnerability scan results
- Suspicious network activity

### Audit Logging

Enable audit logging to track:
- Admin access attempts
- Configuration changes
- Secret access
- Certificate operations
- Security policy violations

## Cost Considerations

### Security vs. Cost

| Feature | Cost Impact | Security Benefit |
|---------|-------------|------------------|
| Pod Security Standards | None | High |
| Secrets Management | None | High |
| TLS Certificates | Low | High |
| Security Scanning | Medium | High |
| Audit Logging | Low-Medium | Medium |

## Integration

This module integrates with:
- **cert-manager**: For TLS certificate management
- **Prometheus**: For security metrics
- **Vulnerability scanners**: For security scanning
- **Audit logging systems**: For compliance
- **Application Helm charts**: For secret consumption

## Compliance

The module helps achieve compliance with:
- **GDPR**: Data protection and encryption
- **SOC 2**: Security controls and monitoring
- **ISO 27001**: Information security management
- **NIST**: Cybersecurity framework compliance
- **CIS Benchmarks**: Kubernetes security best practices