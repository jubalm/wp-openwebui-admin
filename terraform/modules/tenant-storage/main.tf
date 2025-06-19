# Tenant Storage Module
# Creates persistent storage resources for WordPress and OpenWebUI

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Storage class for IONOS persistent volumes (if custom storage class needed)
resource "kubernetes_storage_class" "tenant_storage" {
  count = var.create_custom_storage_class ? 1 : 0

  metadata {
    name = "${var.tenant_id}-storage"
    labels = {
      "tenant-id" = var.tenant_id
    }
  }

  storage_provisioner    = var.storage_provisioner
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  
  parameters = var.storage_parameters
}

# PVC for WordPress database (MySQL)
resource "kubernetes_persistent_volume_claim" "wordpress_db" {
  metadata {
    name      = "${var.tenant_id}-wordpress-db"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
      "app"       = "wordpress"
      "component" = "database"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = var.wordpress_db_storage_size
      }
    }
    
    storage_class_name = var.create_custom_storage_class ? kubernetes_storage_class.tenant_storage[0].metadata[0].name : var.storage_class_name
  }
}

# PVC for WordPress uploads and content
resource "kubernetes_persistent_volume_claim" "wordpress_content" {
  metadata {
    name      = "${var.tenant_id}-wordpress-content"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
      "app"       = "wordpress"
      "component" = "content"
    }
  }

  spec {
    access_modes = ["ReadWriteMany"]
    
    resources {
      requests = {
        storage = var.wordpress_content_storage_size
      }
    }
    
    storage_class_name = var.create_custom_storage_class ? kubernetes_storage_class.tenant_storage[0].metadata[0].name : var.storage_class_name
  }
}

# PVC for OpenWebUI data
resource "kubernetes_persistent_volume_claim" "openwebui_data" {
  metadata {
    name      = "${var.tenant_id}-openwebui-data"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
      "app"       = "openwebui"
      "component" = "data"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = var.openwebui_storage_size
      }
    }
    
    storage_class_name = var.create_custom_storage_class ? kubernetes_storage_class.tenant_storage[0].metadata[0].name : var.storage_class_name
  }
}

# Secret for database credentials
resource "kubernetes_secret" "database_credentials" {
  metadata {
    name      = "${var.tenant_id}-db-credentials"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
    }
  }

  type = "Opaque"

  data = {
    mysql_root_password = base64encode(var.mysql_root_password != null ? var.mysql_root_password : random_password.mysql_root.result)
    mysql_database      = base64encode(var.mysql_database)
    mysql_user          = base64encode(var.mysql_user)
    mysql_password      = base64encode(var.mysql_password != null ? var.mysql_password : random_password.mysql_user.result)
  }
}

# Generate random passwords if not provided
resource "random_password" "mysql_root" {
  length  = 32
  special = true
}

resource "random_password" "mysql_user" {
  length  = 32
  special = true
}

# ConfigMap for database configuration
resource "kubernetes_config_map" "database_config" {
  metadata {
    name      = "${var.tenant_id}-db-config"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
    }
  }

  data = {
    mysql_database = var.mysql_database
    mysql_user     = var.mysql_user
    mysql_host     = "${var.tenant_id}-mysql"
    mysql_port     = "3306"
  }
}

# Backup configuration (placeholder for future implementation)
resource "kubernetes_config_map" "backup_config" {
  count = var.enable_backup_config ? 1 : 0

  metadata {
    name      = "${var.tenant_id}-backup-config"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
    }
  }

  data = {
    backup_schedule        = var.backup_schedule
    backup_retention_days  = tostring(var.backup_retention_days)
    backup_storage_class   = var.backup_storage_class
    backup_enabled         = "true"
  }
}