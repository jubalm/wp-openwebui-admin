# Main Tenant Module
# Orchestrates all tenant infrastructure components

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

# Generate namespace name if not provided
locals {
  namespace_name = var.namespace_name != null ? var.namespace_name : "${var.tenant_id}-ns"
}

# Tenant namespace and RBAC
module "namespace" {
  source = "../tenant-namespace"

  tenant_id       = var.tenant_id
  namespace_name  = local.namespace_name
  environment     = var.environment

  # Resource quotas
  cpu_requests    = var.cpu_requests
  memory_requests = var.memory_requests
  cpu_limits      = var.cpu_limits
  memory_limits   = var.memory_limits
  pvc_count       = var.pvc_count
  pod_count       = var.pod_count
  service_count   = var.service_count

  # Container defaults
  default_cpu_limit      = var.default_cpu_limit
  default_memory_limit   = var.default_memory_limit
  default_cpu_request    = var.default_cpu_request
  default_memory_request = var.default_memory_request
}

# Tenant storage
module "storage" {
  source = "../tenant-storage"

  tenant_id      = var.tenant_id
  namespace_name = module.namespace.namespace_name

  # Storage configuration
  storage_class_name           = var.storage_class_name
  create_custom_storage_class  = var.create_custom_storage_class
  storage_provisioner          = var.storage_provisioner
  storage_parameters           = var.storage_parameters

  # Storage sizes
  wordpress_db_storage_size      = var.wordpress_db_storage_size
  wordpress_content_storage_size = var.wordpress_content_storage_size
  openwebui_storage_size         = var.openwebui_storage_size

  # Database configuration
  mysql_database      = var.mysql_database
  mysql_user          = var.mysql_user
  mysql_root_password = var.mysql_root_password
  mysql_password      = var.mysql_password

  # Backup configuration
  enable_backup_config   = var.enable_backup_config
  backup_schedule        = var.backup_schedule
  backup_retention_days  = var.backup_retention_days
  backup_storage_class   = var.backup_storage_class

  depends_on = [module.namespace]
}

# Tenant security
module "security" {
  source = "../tenant-security"

  tenant_id      = var.tenant_id
  namespace_name = module.namespace.namespace_name

  # Pod security
  pod_security_standard = var.pod_security_standard

  # WordPress security
  wp_admin_user          = var.wp_admin_user
  wp_admin_email         = var.wp_admin_email
  wp_admin_password      = var.wp_admin_password
  wp_auth_key           = var.wp_auth_key
  wp_secure_auth_key    = var.wp_secure_auth_key
  wp_logged_in_key      = var.wp_logged_in_key
  wp_nonce_key          = var.wp_nonce_key
  wp_auth_salt          = var.wp_auth_salt
  wp_secure_auth_salt   = var.wp_secure_auth_salt
  wp_logged_in_salt     = var.wp_logged_in_salt
  wp_nonce_salt         = var.wp_nonce_salt

  # OpenWebUI security
  openwebui_admin_email    = var.openwebui_admin_email
  openwebui_admin_password = var.openwebui_admin_password
  openwebui_jwt_secret     = var.openwebui_jwt_secret
  openai_api_key           = var.openai_api_key

  # TLS configuration
  enable_tls           = var.enable_tls
  cert_manager_issuer  = var.cert_manager_issuer
  base_domain          = var.base_domain
  wordpress_domain     = var.wordpress_domain

  # Security scanning
  enable_security_scanning     = var.enable_security_scanning
  security_scan_schedule       = var.security_scan_schedule
  scan_medium_vulnerabilities  = var.scan_medium_vulnerabilities
  scan_low_vulnerabilities     = var.scan_low_vulnerabilities

  # Monitoring
  log_level            = var.log_level
  enable_audit_logging = var.enable_audit_logging

  depends_on = [module.namespace]
}

# Tenant networking
module "networking" {
  source = "../tenant-networking"

  tenant_id      = var.tenant_id
  namespace_name = module.namespace.namespace_name

  # External IPs
  wordpress_external_ip = var.wordpress_external_ip
  openwebui_external_ip = var.openwebui_external_ip

  # DNS configuration
  enable_custom_dns = var.enable_custom_dns
  base_domain       = var.base_domain
  wordpress_domain  = var.wordpress_domain
  openwebui_domain  = var.openwebui_domain

  # LoadBalancer configuration
  enable_session_affinity   = var.enable_session_affinity
  loadbalancer_annotations  = var.loadbalancer_annotations

  depends_on = [module.namespace, module.security]
}