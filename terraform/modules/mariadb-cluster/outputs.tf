output "cluster_id" {
  description = "The ID of the MariaDB cluster"
  value       = ionoscloud_mariadb_cluster.wordpress_cluster.id
}

output "cluster_dns_name" {
  description = "The DNS name of the MariaDB cluster"
  value       = ionoscloud_mariadb_cluster.wordpress_cluster.dns_name
}

output "cluster_host" {
  description = "The hostname of the MariaDB cluster"
  value       = ionoscloud_mariadb_cluster.wordpress_cluster.dns_name
}

output "cluster_port" {
  description = "The port of the MariaDB cluster"
  value       = 3306
}

output "admin_username" {
  description = "Admin username for the MariaDB cluster"
  value       = var.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "Admin password for the MariaDB cluster"
  value       = var.admin_password
  sensitive   = true
}

output "connection_string" {
  description = "Connection string for the MariaDB cluster"
  value       = "${ionoscloud_mariadb_cluster.wordpress_cluster.dns_name}:3306"
}