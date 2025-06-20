# IONOS infrastructure setup - PostgreSQL cluster for Authentik
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

# Deploy shared infrastructure (datacenter + PostgreSQL cluster for Authentik)
module "infrastructure" {
  source = "../../modules/infrastructure"
  
  # IONOS Cloud configuration
  ionos_token = var.ionos_token
  lan_id      = var.lan_id
  location    = var.location
  
  # PostgreSQL cluster configuration for Authentik
  postgres_cluster_name    = var.postgres_cluster_name
  postgres_version         = var.postgres_version
  postgres_instances       = var.postgres_instances
  postgres_cores          = var.postgres_cores
  postgres_ram            = var.postgres_ram
  postgres_storage_size   = var.postgres_storage_size
  postgres_storage_type   = var.postgres_storage_type
  
  # Security
  allowed_cidr = var.allowed_cidr
  
  # Credentials
  postgres_admin_username = var.postgres_admin_username
  postgres_admin_password = var.postgres_admin_password
  
  # Maintenance
  maintenance_day  = var.maintenance_day
  maintenance_time = var.maintenance_time
}