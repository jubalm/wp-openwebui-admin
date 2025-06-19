# Tenant Networking Module

This Terraform module creates IONOS Cloud LoadBalancers and networking resources for external access to tenant applications. It provides isolated networking for WordPress and OpenWebUI services with proper DNS configuration.

## Features

- **IONOS LoadBalancers**: Automatic provisioning of public LoadBalancers for WordPress and OpenWebUI
- **Internal Services**: ClusterIP services for inter-service communication
- **DNS Configuration**: Automatic domain mapping and internal FQDN generation
- **Network Policies**: External access rules for LoadBalancer traffic
- **Session Affinity**: Configurable session stickiness for WordPress
- **Custom Domains**: Support for custom domain names per tenant

## Usage

```hcl
module "tenant_networking" {
  source = "./modules/tenant-networking"

  tenant_id      = "tenant-001"
  namespace_name = "tenant-001-ns"
  
  # Domain configuration
  base_domain      = "example.com"
  wordpress_domain = "tenant001-wp.example.com"
  openwebui_domain = "tenant001-ui.example.com"
  
  # External IP configuration (optional)
  wordpress_external_ip = "198.51.100.10"
  openwebui_external_ip = "198.51.100.11"
  
  # LoadBalancer configuration
  enable_session_affinity = true
  loadbalancer_annotations = {
    "service.beta.kubernetes.io/ionos-load-balancer-session-timeout" = "300"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| kubernetes | ~> 2.20 |

## Providers

| Name | Version |
|------|---------|
| kubernetes | ~> 2.20 |

## Resources

| Name | Type |
|------|------|
| kubernetes_service.wordpress_loadbalancer | resource |
| kubernetes_service.openwebui_loadbalancer | resource |
| kubernetes_service.wordpress_internal | resource |
| kubernetes_service.openwebui_internal | resource |
| kubernetes_config_map.dns_config | resource |
| kubernetes_network_policy.external_access | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tenant_id | Unique identifier for the tenant | `string` | n/a | yes |
| namespace_name | Name of the Kubernetes namespace for the tenant | `string` | n/a | yes |
| wordpress_external_ip | Specific external IP for WordPress LoadBalancer | `string` | `null` | no |
| openwebui_external_ip | Specific external IP for OpenWebUI LoadBalancer | `string` | `null` | no |
| enable_custom_dns | Enable custom DNS configuration | `bool` | `true` | no |
| base_domain | Base domain for tenant subdomains | `string` | `"example.com"` | no |
| wordpress_domain | Custom domain for WordPress | `string` | `null` | no |
| openwebui_domain | Custom domain for OpenWebUI | `string` | `null` | no |
| enable_session_affinity | Enable session affinity for WordPress | `bool` | `true` | no |
| loadbalancer_annotations | Additional annotations for LoadBalancer services | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| wordpress_loadbalancer_ip | External IP address of the WordPress LoadBalancer |
| openwebui_loadbalancer_ip | External IP address of the OpenWebUI LoadBalancer |
| wordpress_service_name | Name of the WordPress LoadBalancer service |
| openwebui_service_name | Name of the OpenWebUI LoadBalancer service |
| wordpress_internal_service_name | Name of the WordPress internal service |
| openwebui_internal_service_name | Name of the OpenWebUI internal service |
| wordpress_internal_fqdn | Internal FQDN for WordPress service |
| openwebui_internal_fqdn | Internal FQDN for OpenWebUI service |
| wordpress_domain | Domain name for WordPress |
| openwebui_domain | Domain name for OpenWebUI |
| dns_config_name | Name of the DNS configuration ConfigMap |
| network_policy_name | Name of the external access network policy |

## IONOS Cloud Integration

### LoadBalancer Configuration

The module creates IONOS LoadBalancers with specific configurations:

```hcl
annotations = {
  "service.beta.kubernetes.io/ionos-load-balancer-type" = "public"
  "service.beta.kubernetes.io/ionos-load-balancer-forwarding-rule" = "http"
  "service.beta.kubernetes.io/ionos-load-balancer-session-affinity" = "ClientIP"
}
```

### Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    IONOS Cloud                              │
│                                                             │
│  ┌─────────────────┐       ┌─────────────────┐             │
│  │ WordPress       │       │ OpenWebUI       │             │
│  │ LoadBalancer    │       │ LoadBalancer    │             │
│  │ IP: X.X.X.X     │       │ IP: Y.Y.Y.Y     │             │
│  │ Ports: 80/443   │       │ Ports: 80/443   │             │
│  └─────────────────┘       └─────────────────┘             │
│           │                          │                     │
│           ▼                          ▼                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │          Kubernetes Cluster (Namespace)                 │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │ WordPress   │  │ OpenWebUI   │  │ MySQL DB    │     │ │
│  │  │ Pod         │  │ Pod         │  │ Pod         │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │           ▲               ▲               ▲             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │ WP Internal │  │ UI Internal │  │ DB Internal │     │ │
│  │  │ Service     │  │ Service     │  │ Service     │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## DNS Configuration

### Automatic Domain Generation

If custom domains are not provided, the module automatically generates:
- WordPress: `{tenant_id}-wp.{base_domain}`
- OpenWebUI: `{tenant_id}-ui.{base_domain}`

### Custom Domains

```hcl
wordpress_domain = "blog.company.com"
openwebui_domain = "ai.company.com"
```

### Internal DNS

The module creates internal FQDNs for service-to-service communication:
- WordPress: `{tenant_id}-wordpress-internal.{namespace}.svc.cluster.local`
- OpenWebUI: `{tenant_id}-openwebui-internal.{namespace}.svc.cluster.local`

## Security Features

### Network Policies

The module creates network policies to:
- Allow ingress from LoadBalancers on ports 80, 443, and 8080
- Restrict access to authorized traffic only
- Enable communication within the tenant namespace

### Session Affinity

WordPress LoadBalancer includes session affinity to ensure users stay on the same backend pod for consistent experience.

## Monitoring

The module supports monitoring through:
- Service annotations for Prometheus scraping
- LoadBalancer health checks
- Network policy compliance monitoring

## Troubleshooting

### LoadBalancer Issues

1. **LoadBalancer Stuck in Pending**:
   ```bash
   kubectl get svc -n <namespace>
   kubectl describe svc <service-name> -n <namespace>
   # Check IONOS Cloud Console for LoadBalancer status
   ```

2. **Cannot Access Services**:
   ```bash
   # Check LoadBalancer IPs
   kubectl get svc -n <namespace> -o wide
   
   # Test connectivity
   curl -I http://<loadbalancer-ip>
   ```

3. **DNS Resolution Issues**:
   ```bash
   # Check DNS configuration
   kubectl get configmap <tenant-id>-dns-config -n <namespace> -o yaml
   
   # Test internal DNS
   kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup <internal-fqdn>
   ```

### Network Policy Debugging

```bash
# Check network policies
kubectl get networkpolicies -n <namespace>
kubectl describe networkpolicy <policy-name> -n <namespace>

# Test pod-to-pod connectivity
kubectl exec -it <pod-name> -n <namespace> -- wget -qO- <target-service>
```

## Examples

### Basic Configuration

```hcl
module "networking" {
  source = "./modules/tenant-networking"
  
  tenant_id      = "acme-corp"
  namespace_name = "acme-corp-ns"
  base_domain    = "acme.com"
}
```

### Advanced Configuration

```hcl
module "networking" {
  source = "./modules/tenant-networking"
  
  tenant_id      = "enterprise-client"
  namespace_name = "enterprise-client-ns"
  
  # Custom domains
  wordpress_domain = "blog.enterprise-client.com"
  openwebui_domain = "ai.enterprise-client.com"
  
  # Specific IPs (if available)
  wordpress_external_ip = "203.0.113.10"
  openwebui_external_ip = "203.0.113.11"
  
  # LoadBalancer customization
  enable_session_affinity = true
  loadbalancer_annotations = {
    "service.beta.kubernetes.io/ionos-load-balancer-session-timeout" = "1800"
    "service.beta.kubernetes.io/ionos-load-balancer-algorithm" = "round_robin"
  }
}
```

## Integration

This module is designed to work with:
- `tenant-namespace` module for namespace isolation
- `tenant-security` module for TLS certificate management
- `tenant-storage` module for persistent data access
- Helm charts for application deployment

## Best Practices

1. **Use Custom Domains**: Provide custom domains for production deployments
2. **Monitor LoadBalancers**: Set up monitoring for LoadBalancer health
3. **DNS Management**: Automate DNS record creation/updates
4. **Security**: Regularly review network policies and access patterns
5. **Cost Optimization**: Monitor LoadBalancer usage and costs