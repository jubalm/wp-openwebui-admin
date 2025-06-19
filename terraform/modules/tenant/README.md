# Tenant Module

This is the main orchestration module that provisions all infrastructure components for a single tenant.

## Features

- Orchestrates all tenant infrastructure components
- Creates Kubernetes namespace with RBAC
- Sets up MariaDB database and user
- Deploys WordPress with MCP plugin and Authentik SSO
- Configures external access via IONOS LoadBalancer

## Usage

```hcl
module "tenant" {
  source = "./modules/tenant"
  
  # Tenant configuration
  tenant_id      = "acme-corp"
  wp_admin_email = "admin@acme-corp.com"
  
  # Database configuration (IONOS MariaDB)
  mariadb_host           = "mariadb-cluster.ionos.com"
  mariadb_admin_user     = "admin"
  mariadb_admin_password = "admin-password"
  
  # Authentik SSO configuration
  authentik_issuer_url    = "https://authentik.platform.com"
  authentik_client_id     = "wordpress-acme-corp"
  authentik_client_secret = "client-secret"
  
  # Resource allocation
  enable_resource_quota = true
  cpu_limit            = "2000m"
  memory_limit         = "4Gi"
  storage_size         = "20Gi"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| tenant_id | Unique identifier for the tenant | string | - | yes |
| wp_admin_email | WordPress admin email address | string | - | yes |
| mariadb_host | IONOS MariaDB cluster hostname | string | - | yes |
| mariadb_admin_user | MariaDB admin username | string | - | yes |
| mariadb_admin_password | MariaDB admin password | string | - | yes |
| authentik_issuer_url | Authentik SSO issuer URL | string | - | yes |
| authentik_client_id | Authentik OIDC client ID | string | - | yes |
| authentik_client_secret | Authentik OIDC client secret | string | - | yes |
| enable_resource_quota | Enable ResourceQuota for the namespace | bool | false | no |
| cpu_limit | CPU limit for the namespace | string | "1000m" | no |
| memory_limit | Memory limit for the namespace | string | "2Gi" | no |
| storage_size | Size of persistent storage for WordPress files | string | "10Gi" | no |
| cpu_requests | CPU requests for WordPress pod | string | "500m" | no |
| memory_requests | Memory requests for WordPress pod | string | "1Gi" | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace_name | Name of the created namespace |
| database_name | Name of the created database |
| wordpress_url | URL to access WordPress (LoadBalancer IP) |
| loadbalancer_ip | External IP address of the LoadBalancer |