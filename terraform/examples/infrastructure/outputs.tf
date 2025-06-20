# Infrastructure outputs

output "datacenter_id" {
  description = "The ID of the datacenter"
  value       = module.infrastructure.datacenter_id
}

output "datacenter_location" {
  description = "The location of the datacenter"
  value       = module.infrastructure.datacenter_location
}

output "postgres_cluster_id" {
  description = "The ID of the PostgreSQL cluster"
  value       = module.infrastructure.postgres_cluster_id
}

output "postgres_cluster_dns_name" {
  description = "The DNS name of the PostgreSQL cluster"
  value       = module.infrastructure.postgres_cluster_dns_name
}

output "postgres_admin_username" {
  description = "Admin username for the PostgreSQL cluster"
  value       = module.infrastructure.postgres_admin_username
  sensitive   = true
}

output "postgres_admin_password" {
  description = "Admin password for the PostgreSQL cluster"
  value       = module.infrastructure.postgres_admin_password
  sensitive   = true
}

output "next_steps" {
  description = "Next steps after infrastructure deployment"
  value = <<-EOT
    IONOS infrastructure deployed successfully!
    
    Infrastructure Details:
    - Datacenter ID: ${module.infrastructure.datacenter_id}
    - Datacenter location: ${module.infrastructure.datacenter_location}
    - PostgreSQL Cluster ID: ${module.infrastructure.postgres_cluster_id}
    - PostgreSQL DNS name: ${module.infrastructure.postgres_cluster_dns_name}
    
    Next Steps:
    1. Configure Authentik to use the PostgreSQL cluster
    2. Deploy tenant modules - each tenant will get its own MariaDB cluster
    3. Set up Authentik SSO and OpenWebUI integration
    
    PostgreSQL Connection Details for Authentik:
    - postgres_host: ${module.infrastructure.postgres_cluster_dns_name}
    - postgres_admin_user: [stored in state - use terraform output]
    - postgres_admin_password: [stored in state - use terraform output]
    
    For tenant deployments:
    - Use datacenter_id: ${module.infrastructure.datacenter_id}
    - Each tenant gets its own MariaDB cluster for privacy
  EOT
}