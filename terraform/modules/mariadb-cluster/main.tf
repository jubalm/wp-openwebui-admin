terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.0"
    }
  }
}

# IONOS MariaDB cluster for multi-tenant WordPress platform
resource "ionoscloud_mariadb_cluster" "wordpress_cluster" {
  display_name    = var.cluster_name
  mariadb_version = var.mariadb_version
  location        = var.location
  
  instances = var.instances
  cores     = var.cores
  ram       = var.ram
  
  storage_size = var.storage_size
  
  connections {
    datacenter_id = var.datacenter_id
    lan_id        = var.lan_id
    cidr          = var.allowed_cidr
  }
  
  maintenance_window {
    day_of_the_week = var.maintenance_day
    time            = var.maintenance_time
  }
  
  credentials {
    username = var.admin_username
    password = var.admin_password
  }
}