# Tenant Security Module Outputs

output "wordpress_secrets_name" {
  description = "Name of the WordPress secrets"
  value       = kubernetes_secret.wordpress_secrets.metadata[0].name
}

output "openwebui_secrets_name" {
  description = "Name of the OpenWebUI secrets"
  value       = kubernetes_secret.openwebui_secrets.metadata[0].name
}

output "tls_certificate_name" {
  description = "Name of the TLS certificate secret"
  value       = var.enable_tls ? kubernetes_secret.tls_certificate[0].metadata[0].name : null
}

output "pod_security_config_name" {
  description = "Name of the pod security configuration"
  value       = kubernetes_config_map.pod_security_config.metadata[0].name
}

output "security_context_config_name" {
  description = "Name of the security context configuration"
  value       = kubernetes_config_map.security_context.metadata[0].name
}

output "monitoring_config_name" {
  description = "Name of the monitoring configuration"
  value       = kubernetes_config_map.monitoring_config.metadata[0].name
}

output "security_scan_config_name" {
  description = "Name of the security scanning configuration"
  value       = var.enable_security_scanning ? kubernetes_config_map.security_scan_config[0].metadata[0].name : null
}

# Sensitive outputs for application configuration
output "wp_admin_user" {
  description = "WordPress admin username"
  value       = var.wp_admin_user
}

output "wp_admin_email" {
  description = "WordPress admin email"
  value       = var.wp_admin_email
}

output "wp_admin_password" {
  description = "WordPress admin password"
  value       = var.wp_admin_password != null ? var.wp_admin_password : random_password.wp_admin_password.result
  sensitive   = true
}

output "openwebui_admin_email" {
  description = "OpenWebUI admin email"
  value       = var.openwebui_admin_email
}

output "openwebui_admin_password" {
  description = "OpenWebUI admin password"
  value       = var.openwebui_admin_password != null ? var.openwebui_admin_password : random_password.openwebui_admin.result
  sensitive   = true
}

output "openwebui_jwt_secret" {
  description = "OpenWebUI JWT secret"
  value       = var.openwebui_jwt_secret != null ? var.openwebui_jwt_secret : random_password.openwebui_jwt.result
  sensitive   = true
}

# Security configuration summary
output "security_summary" {
  description = "Summary of security configurations applied"
  value = {
    pod_security_standard    = var.pod_security_standard
    tls_enabled             = var.enable_tls
    security_scanning       = var.enable_security_scanning
    audit_logging          = var.enable_audit_logging
    log_level              = var.log_level
    cert_manager_issuer    = var.cert_manager_issuer
  }
}