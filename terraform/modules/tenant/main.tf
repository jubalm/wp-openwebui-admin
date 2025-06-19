# Main tenant orchestration module
# This module coordinates all the components needed for a single tenant

# Create namespace for tenant isolation
module "namespace" {
  source = "../tenant-namespace"
  
  tenant_id             = var.tenant_id
  enable_resource_quota = var.enable_resource_quota
  cpu_limit            = var.cpu_limit
  memory_limit         = var.memory_limit
  storage_limit        = var.storage_size
}

# Create database for tenant WordPress
module "database" {
  source = "../tenant-database"
  
  tenant_id              = var.tenant_id
  namespace              = module.namespace.namespace_name
  mariadb_host           = var.mariadb_host
  mariadb_admin_user     = var.mariadb_admin_user
  mariadb_admin_password = var.mariadb_admin_password
  
  depends_on = [module.namespace]
}

# Deploy WordPress with MCP plugin and Authentik SSO
module "wordpress" {
  source = "../tenant-wordpress"
  
  tenant_id            = var.tenant_id
  namespace            = module.namespace.namespace_name
  database_secret_name = module.database.secret_name
  
  wp_admin_email = var.wp_admin_email
  wp_site_url    = "http://placeholder-ip"  # Will be updated after LoadBalancer IP is assigned
  
  authentik_issuer_url    = var.authentik_issuer_url
  authentik_client_id     = var.authentik_client_id
  authentik_client_secret = var.authentik_client_secret
  
  storage_size    = var.storage_size
  cpu_requests    = var.cpu_requests
  memory_requests = var.memory_requests
  
  depends_on = [module.database]
}