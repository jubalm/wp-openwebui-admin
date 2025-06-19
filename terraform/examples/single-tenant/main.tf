# Example single tenant configuration with existing IONOS MariaDB cluster
# Deploy infrastructure first using the infrastructure example

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0"
    }
  }
}

# Configure Kubernetes provider for IONOS Managed Kubernetes
provider "kubernetes" {
  config_path = "~/.kube/config"  # Update with your kubeconfig path
}

# Configure MySQL provider for MariaDB access
provider "mysql" {
  endpoint = "${var.mariadb_host}:${var.mariadb_port}"
  username = var.mariadb_admin_user
  password = var.mariadb_admin_password
}

# Example tenant deployment
module "example_tenant" {
  source = "../../modules/tenant"
  
  # Tenant configuration
  tenant_id      = "example-tenant"
  wp_admin_email = "admin@example-tenant.com"
  
  # IONOS MariaDB configuration (from infrastructure deployment)
  mariadb_host           = var.mariadb_host
  mariadb_admin_user     = var.mariadb_admin_user
  mariadb_admin_password = var.mariadb_admin_password
  
  # Authentik SSO configuration
  authentik_issuer_url    = var.authentik_issuer_url
  authentik_client_id     = "wordpress-example-tenant"
  authentik_client_secret = var.authentik_client_secret
  
  # Resource allocation for demo
  enable_resource_quota = true
  cpu_limit            = "1500m"
  memory_limit         = "3Gi"
  storage_size         = "15Gi"
  
  # WordPress pod resources
  cpu_requests    = "250m"
  memory_requests = "512Mi"
}