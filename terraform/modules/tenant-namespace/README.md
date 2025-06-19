# Tenant Namespace Module

This Terraform module creates a Kubernetes namespace with proper tenant isolation using RBAC, NetworkPolicies, and resource quotas. This module implements the namespace-based isolation strategy for the multi-tenant WordPress and OpenWebUI platform.

## Features

- **Kubernetes Namespace**: Creates an isolated namespace for tenant resources
- **RBAC Configuration**: Service account, role, and role binding for secure access
- **Network Policies**: Strict ingress/egress rules for network isolation
- **Resource Quotas**: CPU, memory, and resource limits per tenant
- **Limit Ranges**: Default resource constraints for containers
- **Security**: Pod Security Standards compatible

## Usage

```hcl
module "tenant_namespace" {
  source = "./modules/tenant-namespace"

  tenant_id     = "tenant-001"
  environment   = "production"
  
  # Resource quotas
  cpu_requests    = "2"
  memory_requests = "4Gi"
  cpu_limits      = "4" 
  memory_limits   = "8Gi"
  
  # Container defaults
  default_cpu_limit      = "500m"
  default_memory_limit   = "1Gi"
  default_cpu_request    = "100m"
  default_memory_request = "256Mi"
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
| kubernetes_namespace.tenant | resource |
| kubernetes_service_account.tenant | resource |
| kubernetes_role.tenant | resource |
| kubernetes_role_binding.tenant | resource |
| kubernetes_network_policy.tenant_isolation | resource |
| kubernetes_resource_quota.tenant | resource |
| kubernetes_limit_range.tenant | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tenant_id | Unique identifier for the tenant | `string` | n/a | yes |
| namespace_name | Name of the Kubernetes namespace for the tenant | `string` | `null` | no |
| environment | Environment (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| cpu_requests | Total CPU requests allowed for the tenant | `string` | `"2"` | no |
| memory_requests | Total memory requests allowed for the tenant | `string` | `"4Gi"` | no |
| cpu_limits | Total CPU limits allowed for the tenant | `string` | `"4"` | no |
| memory_limits | Total memory limits allowed for the tenant | `string` | `"8Gi"` | no |
| pvc_count | Number of persistent volume claims allowed | `string` | `"10"` | no |
| pod_count | Number of pods allowed | `string` | `"20"` | no |
| service_count | Number of services allowed | `string` | `"10"` | no |
| default_cpu_limit | Default CPU limit for containers | `string` | `"500m"` | no |
| default_memory_limit | Default memory limit for containers | `string` | `"1Gi"` | no |
| default_cpu_request | Default CPU request for containers | `string` | `"100m"` | no |
| default_memory_request | Default memory request for containers | `string` | `"256Mi"` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace_name | Name of the created namespace |
| service_account_name | Name of the tenant service account |
| service_account_token_secret_name | Name of the service account token secret |
| namespace_labels | Labels applied to the namespace |
| resource_quota_name | Name of the resource quota |
| limit_range_name | Name of the limit range |
| network_policy_name | Name of the network policy |
| role_name | Name of the RBAC role |
| role_binding_name | Name of the RBAC role binding |

## Security Considerations

- **Network Isolation**: NetworkPolicies restrict traffic to same namespace and necessary system namespaces
- **RBAC**: Minimal permissions granted to tenant service account
- **Resource Limits**: Prevents resource exhaustion attacks
- **Namespace Labels**: Enables policy enforcement and monitoring

## Integration

This module is designed to work with:
- `tenant-networking` module for LoadBalancer and ingress configuration
- `tenant-storage` module for persistent volume management
- `tenant-security` module for additional security policies

## Examples

See the `examples/` directory for complete tenant provisioning examples.