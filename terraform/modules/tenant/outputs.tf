# Main Tenant Module Outputs
# Consolidated outputs from all tenant infrastructure components

# === NAMESPACE OUTPUTS ===
output "namespace_name" {
  description = "Name of the created namespace"
  value       = module.namespace.namespace_name
}

output "service_account_name" {
  description = "Name of the tenant service account"
  value       = module.namespace.service_account_name
}

output "resource_quota_name" {
  description = "Name of the resource quota"
  value       = module.namespace.resource_quota_name
}

# === STORAGE OUTPUTS ===
output "storage" {
  description = "Storage-related outputs"
  value = {
    wordpress_db_pvc_name      = module.storage.wordpress_db_pvc_name
    wordpress_content_pvc_name = module.storage.wordpress_content_pvc_name
    openwebui_data_pvc_name    = module.storage.openwebui_data_pvc_name
    database_credentials_name  = module.storage.database_credentials_secret_name
    database_config_name       = module.storage.database_config_name
    storage_class_name         = module.storage.storage_class_name
    mysql_host                 = module.storage.mysql_host
    mysql_database             = module.storage.mysql_database
    mysql_user                 = module.storage.mysql_user
    storage_sizes              = module.storage.storage_sizes
  }
}

# === SECURITY OUTPUTS ===
output "security" {
  description = "Security-related outputs"
  value = {
    wordpress_secrets_name     = module.security.wordpress_secrets_name
    openwebui_secrets_name     = module.security.openwebui_secrets_name
    tls_certificate_name       = module.security.tls_certificate_name
    pod_security_config_name   = module.security.pod_security_config_name
    security_context_config_name = module.security.security_context_config_name
    monitoring_config_name     = module.security.monitoring_config_name
    wp_admin_user             = module.security.wp_admin_user
    wp_admin_email            = module.security.wp_admin_email
    openwebui_admin_email     = module.security.openwebui_admin_email
    security_summary          = module.security.security_summary
  }
}

# === NETWORKING OUTPUTS ===
output "networking" {
  description = "Networking-related outputs"
  value = {
    wordpress_loadbalancer_ip  = module.networking.wordpress_loadbalancer_ip
    openwebui_loadbalancer_ip  = module.networking.openwebui_loadbalancer_ip
    wordpress_service_name     = module.networking.wordpress_service_name
    openwebui_service_name     = module.networking.openwebui_service_name
    wordpress_internal_service = module.networking.wordpress_internal_service_name
    openwebui_internal_service = module.networking.openwebui_internal_service_name
    wordpress_internal_fqdn    = module.networking.wordpress_internal_fqdn
    openwebui_internal_fqdn    = module.networking.openwebui_internal_fqdn
    wordpress_domain           = module.networking.wordpress_domain
    openwebui_domain           = module.networking.openwebui_domain
    dns_config_name           = module.networking.dns_config_name
  }
}

# === SENSITIVE OUTPUTS ===
output "database_credentials" {
  description = "Database credentials (sensitive)"
  value = {
    mysql_root_password = module.storage.mysql_root_password
    mysql_password      = module.storage.mysql_password
  }
  sensitive = true
}

output "application_credentials" {
  description = "Application admin credentials (sensitive)"
  value = {
    wp_admin_password         = module.security.wp_admin_password
    openwebui_admin_password  = module.security.openwebui_admin_password
    openwebui_jwt_secret      = module.security.openwebui_jwt_secret
  }
  sensitive = true
}

# === SUMMARY OUTPUT ===
output "tenant_summary" {
  description = "Summary of tenant infrastructure"
  value = {
    tenant_id           = var.tenant_id
    namespace           = module.namespace.namespace_name
    environment         = var.environment
    wordpress_domain    = module.networking.wordpress_domain
    openwebui_domain    = module.networking.openwebui_domain
    wordpress_ip        = module.networking.wordpress_loadbalancer_ip
    openwebui_ip        = module.networking.openwebui_loadbalancer_ip
    storage_total       = module.storage.storage_sizes.total_size
    security_standard   = module.security.security_summary.pod_security_standard
    tls_enabled         = module.security.security_summary.tls_enabled
    created_at          = timestamp()
  }
}

# === ACCESS INFORMATION ===
output "access_info" {
  description = "Access information for the tenant"
  value = {
    wordpress_url       = "https://${module.networking.wordpress_domain}"
    openwebui_url       = "https://${module.networking.openwebui_domain}"
    wordpress_ip        = module.networking.wordpress_loadbalancer_ip
    openwebui_ip        = module.networking.openwebui_loadbalancer_ip
    wp_admin_user       = module.security.wp_admin_user
    wp_admin_email      = module.security.wp_admin_email
    openwebui_admin_email = module.security.openwebui_admin_email
    namespace           = module.namespace.namespace_name
  }
}