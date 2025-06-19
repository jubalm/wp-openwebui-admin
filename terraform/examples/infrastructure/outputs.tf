# Infrastructure outputs

output "mariadb_cluster_id" {
  description = "The ID of the MariaDB cluster"
  value       = module.infrastructure.mariadb_cluster_id
}

output "mariadb_cluster_host" {
  description = "The hostname of the MariaDB cluster"
  value       = module.infrastructure.mariadb_cluster_host
}

output "mariadb_cluster_port" {
  description = "The port of the MariaDB cluster"
  value       = module.infrastructure.mariadb_cluster_port
}

output "mariadb_connection_string" {
  description = "Connection string for the MariaDB cluster"
  value       = module.infrastructure.mariadb_connection_string
}

output "mariadb_admin_username" {
  description = "Admin username for the MariaDB cluster"
  value       = module.infrastructure.mariadb_admin_username
  sensitive   = true
}

output "mariadb_admin_password" {
  description = "Admin password for the MariaDB cluster"
  value       = module.infrastructure.mariadb_admin_password
  sensitive   = true
}

output "next_steps" {
  description = "Next steps after infrastructure deployment"
  value = <<-EOT
    IONOS MariaDB cluster deployed successfully!
    
    Infrastructure Details:
    - Cluster ID: ${module.infrastructure.mariadb_cluster_id}
    - Hostname: ${module.infrastructure.mariadb_cluster_host}
    - Connection String: ${module.infrastructure.mariadb_connection_string}
    
    Next Steps:
    1. Configure your tenant deployments to use these connection details
    2. Deploy tenant modules with the MariaDB cluster information
    3. Set up Authentik SSO and OpenWebUI integration
    
    Connection Details for Tenant Configuration:
    - mariadb_host: ${module.infrastructure.mariadb_cluster_host}
    - mariadb_admin_user: [stored in state - use terraform output]
    - mariadb_admin_password: [stored in state - use terraform output]
  EOT
}