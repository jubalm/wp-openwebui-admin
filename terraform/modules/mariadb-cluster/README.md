# MariaDB Cluster Module

This module creates an IONOS MariaDB managed database cluster for the multi-tenant WordPress platform.

## Features

- Creates IONOS MariaDB cluster with configurable sizing
- Automatic backups and maintenance windows
- Network security with CIDR-based access control
- Outputs connection details for use by tenant modules

## Usage

```hcl
module "mariadb_cluster" {
  source = "./modules/mariadb-cluster"
  
  cluster_name = "wp-openwebui-mariadb"
  
  # Infrastructure configuration
  datacenter_id = "12345678-1234-1234-1234-123456789012"
  lan_id        = "1"
  location      = "de/fra"
  
  # Database configuration
  mariadb_version = "10.6"
  instances       = 1
  cores          = 2
  ram            = 4096
  storage_size   = 20
  storage_type   = "HDD"
  
  # Security
  allowed_cidr = "10.0.0.0/8"
  
  # Credentials
  admin_username = "admin"
  admin_password = "secure-password"
  
  # Maintenance
  maintenance_day  = "Sunday"
  maintenance_time = "03:00:00"
  backup_location  = "de"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| ionoscloud | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| ionoscloud | ~> 6.0 |

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
| allowed_cidr | CIDR block allowed to connect to MariaDB | `string` | `"0.0.0.0/0"` | no |
| maintenance_day | Day of the week for maintenance | `string` | `"Sunday"` | no |
| maintenance_time | Time for maintenance (HH:MM:SS) | `string` | `"03:00:00"` | no |
| admin_username | Admin username for MariaDB | `string` | n/a | yes |
| admin_password | Admin password for MariaDB | `string` | n/a | yes |
| backup_location | Backup location | `string` | `"de"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the MariaDB cluster |
| cluster_dns_name | The DNS name of the MariaDB cluster |
| cluster_host | The hostname of the MariaDB cluster |
| cluster_port | The port of the MariaDB cluster |
| admin_username | Admin username for the MariaDB cluster |
| admin_password | Admin password for the MariaDB cluster |
| connection_string | Connection string for the MariaDB cluster |

## Resource Types

This module creates the following resources:

- `ionoscloud_mariadb_cluster.wordpress_cluster` - The main MariaDB cluster resource