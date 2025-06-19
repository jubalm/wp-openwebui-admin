# Tenant WordPress Module

This module deploys a WordPress instance for a tenant with MCP plugin and Authentik SSO integration.

## Features

- Deploys WordPress with MCP plugin pre-installed
- Configures Authentik SSO integration
- Sets up LoadBalancer for external access
- Creates persistent storage for WordPress files
- Generates WordPress authentication keys/salts

## Usage

```hcl
module "tenant_wordpress" {
  source = "./modules/tenant-wordpress"
  
  tenant_id   = "example-tenant"
  namespace   = "tenant-example-tenant"
  
  # Database configuration
  database_secret_name = "database-credentials"
  
  # WordPress configuration
  wp_admin_email = "admin@example-tenant.com"
  wp_site_url    = "http://203.0.113.1"  # LoadBalancer IP
  
  # Authentik SSO configuration
  authentik_issuer_url = "https://authentik.example.com"
  authentik_client_id  = "wordpress-example-tenant"
  authentik_client_secret = "client-secret"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| tenant_id | Unique identifier for the tenant | string | - | yes |
| namespace | Kubernetes namespace for the tenant | string | - | yes |
| database_secret_name | Name of the database credentials secret | string | - | yes |
| wp_admin_email | WordPress admin email address | string | - | yes |
| wp_site_url | WordPress site URL (LoadBalancer IP) | string | - | yes |
| authentik_issuer_url | Authentik SSO issuer URL | string | - | yes |
| authentik_client_id | Authentik OIDC client ID | string | - | yes |
| authentik_client_secret | Authentik OIDC client secret | string | - | yes |
| storage_size | Size of persistent storage for WordPress files | string | "10Gi" | no |
| cpu_requests | CPU requests for WordPress pod | string | "500m" | no |
| memory_requests | Memory requests for WordPress pod | string | "1Gi" | no |

## Outputs

| Name | Description |
|------|-------------|
| loadbalancer_ip | External IP address of the LoadBalancer |
| service_name | Name of the WordPress service |