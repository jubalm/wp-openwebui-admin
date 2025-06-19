terraform {
  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure MySQL provider for IONOS MariaDB
provider "mysql" {
  endpoint = "${var.mariadb_host}:${var.mariadb_port}"
  username = var.mariadb_admin_user
  password = var.mariadb_admin_password
}

# Local values for consistent naming
locals {
  database_name = replace("wp_${var.tenant_id}", "-", "_")
  database_user = replace("wp_user_${var.tenant_id}", "-", "_")
}

# Generate secure random password for database user
resource "random_password" "database_password" {
  length  = 32
  special = true
}

# Create database for tenant WordPress
resource "mysql_database" "wordpress" {
  name = local.database_name
}

# Create database user for tenant WordPress
resource "mysql_user" "wordpress" {
  user     = local.database_user
  host     = "%"
  password = random_password.database_password.result
}

# Grant permissions to database user
resource "mysql_grant" "wordpress" {
  user       = mysql_user.wordpress.user
  host       = mysql_user.wordpress.host
  database   = mysql_database.wordpress.name
  privileges = ["ALL PRIVILEGES"]
}

# Create Kubernetes secret with database credentials
resource "kubernetes_secret" "database_credentials" {
  metadata {
    name      = "database-credentials"
    namespace = var.namespace
    
    labels = {
      "app.kubernetes.io/name"      = "wordpress"
      "app.kubernetes.io/component" = "database"
      "tenant.platform/id"          = var.tenant_id
    }
  }

  data = {
    DB_HOST     = var.mariadb_host
    DB_PORT     = var.mariadb_port
    DB_NAME     = mysql_database.wordpress.name
    DB_USER     = mysql_user.wordpress.user
    DB_PASSWORD = random_password.database_password.result
  }

  type = "Opaque"
}