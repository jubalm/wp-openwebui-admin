# Tenant Storage Module Outputs

output "wordpress_db_pvc_name" {
  description = "Name of the WordPress database PVC"
  value       = kubernetes_persistent_volume_claim.wordpress_db.metadata[0].name
}

output "wordpress_content_pvc_name" {
  description = "Name of the WordPress content PVC"
  value       = kubernetes_persistent_volume_claim.wordpress_content.metadata[0].name
}

output "openwebui_data_pvc_name" {
  description = "Name of the OpenWebUI data PVC"
  value       = kubernetes_persistent_volume_claim.openwebui_data.metadata[0].name
}

output "database_credentials_secret_name" {
  description = "Name of the database credentials secret"
  value       = kubernetes_secret.database_credentials.metadata[0].name
}

output "database_config_name" {
  description = "Name of the database configuration ConfigMap"
  value       = kubernetes_config_map.database_config.metadata[0].name
}

output "backup_config_name" {
  description = "Name of the backup configuration ConfigMap"
  value       = var.enable_backup_config ? kubernetes_config_map.backup_config[0].metadata[0].name : null
}

output "storage_class_name" {
  description = "Name of the storage class used"
  value       = var.create_custom_storage_class ? kubernetes_storage_class.tenant_storage[0].metadata[0].name : var.storage_class_name
}

output "mysql_database" {
  description = "MySQL database name"
  value       = var.mysql_database
}

output "mysql_user" {
  description = "MySQL user name"
  value       = var.mysql_user
}

output "mysql_host" {
  description = "MySQL host name"
  value       = "${var.tenant_id}-mysql"
}

# Sensitive outputs
output "mysql_root_password" {
  description = "MySQL root password"
  value       = var.mysql_root_password != null ? var.mysql_root_password : random_password.mysql_root.result
  sensitive   = true
}

output "mysql_password" {
  description = "MySQL user password"
  value       = var.mysql_password != null ? var.mysql_password : random_password.mysql_user.result
  sensitive   = true
}

# Storage sizes for reference
output "storage_sizes" {
  description = "Storage sizes allocated for the tenant"
  value = {
    wordpress_db      = var.wordpress_db_storage_size
    wordpress_content = var.wordpress_content_storage_size
    openwebui_data    = var.openwebui_storage_size
    total_size        = "${sum([
      parseint(replace(var.wordpress_db_storage_size, "Gi", ""), 10),
      parseint(replace(var.wordpress_content_storage_size, "Gi", ""), 10),
      parseint(replace(var.openwebui_storage_size, "Gi", ""), 10)
    ])}Gi"
  }
}