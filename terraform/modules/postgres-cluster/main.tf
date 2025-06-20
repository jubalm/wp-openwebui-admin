terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.0"
    }
  }
}

# IONOS PostgreSQL cluster for Authentik
resource "ionoscloud_pg_cluster" "authentik_cluster" {
  postgres_version = var.postgres_version
  instances        = var.instances
  cores            = var.cores
  ram              = var.ram
  storage_size     = var.storage_size
  storage_type     = var.storage_type
  location         = var.location

  display_name = var.cluster_name

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