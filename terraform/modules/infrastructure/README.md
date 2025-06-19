# Infrastructure Module

This module provisions the shared infrastructure components for the multi-tenant WordPress + OpenWebUI platform on IONOS Cloud.

## Features

- Creates IONOS MariaDB managed cluster for all tenants
- Configurable cluster sizing and maintenance windows
- Outputs connection details for tenant modules

## Usage

```hcl
module "infrastructure" {
  source = "./modules/infrastructure"
  
  # IONOS Cloud configuration
  datacenter_id = "12345678-1234-1234-1234-123456789012"
  lan_id        = "1"
  location      = "de/fra"
  
  # MariaDB cluster configuration
  cluster_name    = "wp-openwebui-mariadb"
  mariadb_version = "10.6"
  instances       = 1
  cores          = 2
  ram            = 4096
  storage_size   = 50
  storage_type   = "SSD"
  
  # Security
  allowed_cidr = "10.0.0.0/8"
  
  # Credentials
  admin_username = "admin"
  admin_password = var.mariadb_admin_password
  
  # Maintenance
  maintenance_day  = "Sunday"
  maintenance_time = "03:00:00"
  backup_location  = "de"
}
```

## Components Created

- **IONOS MariaDB Cluster**: Managed database cluster for all tenant databases

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| ionoscloud | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| ionoscloud | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| mariadb_cluster | ../mariadb-cluster | n/a |

## Resources

No resources created directly by this module.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Display name for the MariaDB cluster | `string` | `"wp-openwebui-mariadb"` | no |
| mariadb_version | MariaDB version | `string` | `"10.6"` | no |
| location | Location for the MariaDB cluster | `string` | `"de/fra"` | no |
| instances | Number of MariaDB instances | `number` | `1` | no |
| cores | Number of CPU cores per instance | `number` | `2` | no |
| ram | RAM in MB per instance | `number` | `4096` | no |
| storage_size | Storage size in GB | `number` | `20` | no |
| storage_type | Storage type | `string` | `"HDD"` | no |
| datacenter_id | IONOS datacenter ID | `string` | n/a | yes |
| lan_id | LAN ID for the MariaDB cluster | `string` | n/a | yes |
| allowed_cidr | CIDR block allowed to connect to MariaDB | `string` | `"10.0.0.0/8"` | no |
| maintenance_day | Day of the week for maintenance | `string` | `"Sunday"` | no |
| maintenance_time | Time for maintenance (HH:MM:SS) | `string` | `"03:00:00"` | no |
| admin_username | Admin username for MariaDB | `string` | n/a | yes |
| admin_password | Admin password for MariaDB | `string` | n/a | yes |
| backup_location | Backup location | `string` | `"de"` | no |

## Outputs

| Name | Description |
|------|-------------|
| mariadb_cluster_id | The ID of the MariaDB cluster |
| mariadb_cluster_host | The hostname of the MariaDB cluster |
| mariadb_cluster_port | The port of the MariaDB cluster |
| mariadb_admin_username | Admin username for the MariaDB cluster |
| mariadb_admin_password | Admin password for the MariaDB cluster |
| mariadb_connection_string | Connection string for the MariaDB cluster |