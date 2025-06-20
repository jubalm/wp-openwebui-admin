output "cluster_id" {
  description = "ID of the PostgreSQL cluster"
  value       = ionoscloud_pg_cluster.authentik_cluster.id
}

output "cluster_dns_name" {
  description = "DNS name of the PostgreSQL cluster"
  value       = ionoscloud_pg_cluster.authentik_cluster.dns_name
}

output "admin_username" {
  description = "Admin username for PostgreSQL"
  value       = var.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "Admin password for PostgreSQL"
  value       = var.admin_password
  sensitive   = true
}

output "postgres_version" {
  description = "PostgreSQL version"
  value       = ionoscloud_pg_cluster.authentik_cluster.postgres_version
}

output "location" {
  description = "Cluster location"
  value       = ionoscloud_pg_cluster.authentik_cluster.location
}