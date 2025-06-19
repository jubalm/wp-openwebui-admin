# Outputs for the example tenant

# Tenant outputs
output "tenant_namespace" {
  description = "Kubernetes namespace for the tenant"
  value       = module.example_tenant.namespace_name
}

output "tenant_database" {
  description = "Database name for the tenant"
  value       = module.example_tenant.database_name
}

output "wordpress_url" {
  description = "URL to access the tenant's WordPress instance"
  value       = module.example_tenant.wordpress_url
}

output "loadbalancer_ip" {
  description = "External IP address assigned by IONOS LoadBalancer"
  value       = module.example_tenant.loadbalancer_ip
}

output "next_steps" {
  description = "Next steps after deployment"
  value = <<-EOT
    WordPress deployment with IONOS MariaDB cluster completed successfully!
    
    1. Access WordPress at: ${module.example_tenant.wordpress_url}
    2. Configure Authentik OIDC client with:
       - Redirect URI: ${module.example_tenant.wordpress_url}/wp-admin/admin-ajax.php?action=openid-connect-authorize
    3. Complete WordPress setup and install MCP plugin
    4. Configure WordPress to integrate with OpenWebUI
    
    Tenant Details:
    - Namespace: ${module.example_tenant.namespace_name}
    - Database: ${module.example_tenant.database_name}
    - LoadBalancer IP: ${module.example_tenant.loadbalancer_ip}
  EOT
}