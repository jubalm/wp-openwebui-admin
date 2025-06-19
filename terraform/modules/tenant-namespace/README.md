# Tenant Namespace Module

This module creates a Kubernetes namespace for a tenant's WordPress instance with basic RBAC and resource management.

## Features

- Creates isolated Kubernetes namespace
- Sets up ServiceAccount for WordPress deployment
- Configures basic RBAC (Role/RoleBinding)
- Optional ResourceQuota for resource limits

## Usage

```hcl
module "tenant_namespace" {
  source = "./modules/tenant-namespace"
  
  tenant_id = "example-tenant"
  
  # Optional resource limits
  enable_resource_quota = true
  cpu_limit            = "2000m"
  memory_limit         = "4Gi"
  storage_limit        = "10Gi"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| tenant_id | Unique identifier for the tenant | string | - | yes |
| enable_resource_quota | Enable ResourceQuota for the namespace | bool | false | no |
| cpu_limit | CPU limit for the namespace | string | "1000m" | no |
| memory_limit | Memory limit for the namespace | string | "2Gi" | no |
| storage_limit | Storage limit for the namespace | string | "5Gi" | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace_name | Name of the created namespace |
| service_account_name | Name of the created ServiceAccount |