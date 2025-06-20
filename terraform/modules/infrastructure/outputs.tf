# Output the datacenter details for use by tenant modules
output "datacenter_id" {
  description = "The ID of the datacenter"
  value       = module.datacenter.datacenter_id
}

output "datacenter_location" {
  description = "The location of the datacenter"
  value       = module.datacenter.datacenter_location
}

# Output the PostgreSQL cluster details for Authentik
output "postgres_cluster_id" {
  description = "The ID of the PostgreSQL cluster"
  value       = module.postgres_cluster.cluster_id
}

output "postgres_cluster_dns_name" {
  description = "The DNS name of the PostgreSQL cluster"
  value       = module.postgres_cluster.cluster_dns_name
}

output "postgres_admin_username" {
  description = "Admin username for the PostgreSQL cluster"
  value       = module.postgres_cluster.admin_username
  sensitive   = true
}

output "postgres_admin_password" {
  description = "Admin password for the PostgreSQL cluster"
  value       = module.postgres_cluster.admin_password
  sensitive   = true
}