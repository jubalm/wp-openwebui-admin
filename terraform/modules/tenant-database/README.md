# Tenant Database Module

This module creates a MariaDB database and user within the IONOS managed MariaDB cluster for a tenant's WordPress instance.

## Features

- Creates isolated database for tenant WordPress
- Sets up database user with appropriate permissions
- Generates secure random password
- Creates Kubernetes secret with database credentials

## Usage

```hcl
module "tenant_database" {
  source = "./modules/tenant-database"
  
  tenant_id = "example-tenant"
  namespace = "tenant-example-tenant"
  
  # Database configuration
  mariadb_host = "mariadb-cluster.ionos.com"
  mariadb_port = 3306
  mariadb_admin_user = "admin"
  mariadb_admin_password = "admin-password"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| tenant_id | Unique identifier for the tenant | string | - | yes |
| namespace | Kubernetes namespace for the tenant | string | - | yes |
| mariadb_host | IONOS MariaDB cluster hostname | string | - | yes |
| mariadb_port | MariaDB port | number | 3306 | no |
| mariadb_admin_user | MariaDB admin username | string | - | yes |
| mariadb_admin_password | MariaDB admin password | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| database_name | Name of the created database |
| database_user | Username for the database |
| secret_name | Name of the Kubernetes secret containing database credentials |