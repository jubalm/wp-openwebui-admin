terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.0"
    }
  }
}

# Create the shared MariaDB cluster for all tenants
module "mariadb_cluster" {
  source = "../mariadb-cluster"
  
  cluster_name = var.cluster_name
  
  # Infrastructure configuration
  datacenter_id = var.datacenter_id
  lan_id        = var.lan_id
  location      = var.location
  
  # Database configuration
  mariadb_version = var.mariadb_version
  instances       = var.instances
  cores          = var.cores
  ram            = var.ram
  storage_size   = var.storage_size
  
  # Security
  allowed_cidr = var.allowed_cidr
  
  # Credentials
  admin_username = var.admin_username
  admin_password = var.admin_password
  
  # Maintenance
  maintenance_day  = var.maintenance_day
  maintenance_time = var.maintenance_time
}