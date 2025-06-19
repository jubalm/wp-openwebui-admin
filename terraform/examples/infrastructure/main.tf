# IONOS infrastructure setup - MariaDB cluster
# This should be deployed first before tenant configurations

terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.0"
    }
  }
}

# Configure IONOS Cloud provider
provider "ionoscloud" {
  token = var.ionos_token
}

# Deploy shared infrastructure (MariaDB cluster)
module "infrastructure" {
  source = "../../modules/infrastructure"
  
  # IONOS Cloud configuration
  datacenter_id = var.datacenter_id
  lan_id        = var.lan_id
  location      = var.location
  
  # MariaDB cluster configuration
  cluster_name    = var.cluster_name
  mariadb_version = var.mariadb_version
  instances       = var.instances
  cores          = var.cores
  ram            = var.ram
  storage_size   = var.storage_size
  
  # Security
  allowed_cidr = var.allowed_cidr
  
  # Credentials
  admin_username = var.mariadb_admin_user
  admin_password = var.mariadb_admin_password
  
  # Maintenance
  maintenance_day  = var.maintenance_day
  maintenance_time = var.maintenance_time
}