# Output the MariaDB cluster details for use by tenant modules
output "mariadb_cluster_id" {
  description = "The ID of the MariaDB cluster"
  value       = module.mariadb_cluster.cluster_id
}

output "mariadb_cluster_host" {
  description = "The hostname of the MariaDB cluster"
  value       = module.mariadb_cluster.cluster_host
}

output "mariadb_cluster_port" {
  description = "The port of the MariaDB cluster"
  value       = module.mariadb_cluster.cluster_port
}

output "mariadb_admin_username" {
  description = "Admin username for the MariaDB cluster"
  value       = module.mariadb_cluster.admin_username
  sensitive   = true
}

output "mariadb_admin_password" {
  description = "Admin password for the MariaDB cluster"
  value       = module.mariadb_cluster.admin_password
  sensitive   = true
}

output "mariadb_connection_string" {
  description = "Connection string for the MariaDB cluster"
  value       = module.mariadb_cluster.connection_string
}