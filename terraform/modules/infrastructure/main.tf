terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.0"
    }
  }
}

# Create the datacenter for the infrastructure
module "datacenter" {
  source = "../datacenter"
  
  ionos_token = var.ionos_token
}

# Create PostgreSQL cluster for Authentik
module "postgres_cluster" {
  source = "../postgres-cluster"
  
  cluster_name = var.postgres_cluster_name
  
  # Infrastructure configuration
  datacenter_id = module.datacenter.datacenter_id
  lan_id        = var.lan_id
  location      = var.location
  
  # Database configuration
  postgres_version = var.postgres_version
  instances        = var.postgres_instances
  cores           = var.postgres_cores
  ram             = var.postgres_ram
  storage_size    = var.postgres_storage_size
  storage_type    = var.postgres_storage_type
  
  # Security
  allowed_cidr = var.allowed_cidr
  
  # Credentials
  admin_username = var.postgres_admin_username
  admin_password = var.postgres_admin_password
  
  # Maintenance
  maintenance_day  = var.maintenance_day
  maintenance_time = var.maintenance_time
}