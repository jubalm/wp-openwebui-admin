# Example single tenant configuration with dedicated IONOS MariaDB cluster
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

# Configure Kubernetes provider for IONOS Managed Kubernetes
provider "kubernetes" {
  config_path = "~/.kube/config"  # Update with your kubeconfig path
}

# Create dedicated MariaDB cluster for this tenant (for privacy)
module "tenant_mariadb" {
  source = "../../modules/mariadb-cluster"
  
  cluster_name = "${var.tenant_id}-mariadb"
  
  # Infrastructure configuration (from infrastructure deployment)
  datacenter_id = var.datacenter_id
  lan_id        = var.lan_id
  location      = var.location
  
  # Database configuration
  mariadb_version = var.mariadb_version
  instances       = var.mariadb_instances
  cores          = var.mariadb_cores
  ram            = var.mariadb_ram
  storage_size   = var.mariadb_storage_size
  
  # Security
  allowed_cidr = var.allowed_cidr
  
  # Credentials
  admin_username = var.mariadb_admin_username
  admin_password = var.mariadb_admin_password
  
  # Maintenance
  maintenance_day  = var.maintenance_day
  maintenance_time = var.maintenance_time
}

# Configure MySQL provider for MariaDB access
provider "mysql" {
  endpoint = "${module.tenant_mariadb.cluster_host}:${module.tenant_mariadb.cluster_port}"
  username = var.mariadb_admin_username
  password = var.mariadb_admin_password
  
  depends_on = [module.tenant_mariadb]
}

# Example tenant deployment
module "example_tenant" {
  source = "../../modules/tenant"
  
  # Tenant configuration
  tenant_id      = var.tenant_id
  wp_admin_email = var.wp_admin_email
  
  # IONOS MariaDB configuration (from dedicated cluster)
  mariadb_host           = module.tenant_mariadb.cluster_host
  mariadb_admin_user     = var.mariadb_admin_username
  mariadb_admin_password = var.mariadb_admin_password
  
  # Authentik SSO configuration
  authentik_issuer_url    = var.authentik_issuer_url
  authentik_client_id     = "${var.tenant_id}-wordpress"
  authentik_client_secret = var.authentik_client_secret
  
  # Resource allocation
  enable_resource_quota = var.enable_resource_quota
  cpu_limit            = var.cpu_limit
  memory_limit         = var.memory_limit
  storage_size         = var.storage_size
  
  # WordPress pod resources
  cpu_requests    = var.cpu_requests
  memory_requests = var.memory_requests
  
  depends_on = [module.tenant_mariadb]
}