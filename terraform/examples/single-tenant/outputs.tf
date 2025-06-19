# Single Tenant Example Outputs

# === TENANT 001 OUTPUTS ===
output "tenant_001_summary" {
  description = "Summary of tenant-001 infrastructure"
  value       = module.tenant_001.tenant_summary
}

output "tenant_001_access" {
  description = "Access information for tenant-001"
  value       = module.tenant_001.access_info
}

output "tenant_001_networking" {
  description = "Networking configuration for tenant-001"
  value       = module.tenant_001.networking
}

output "tenant_001_storage" {
  description = "Storage configuration for tenant-001"
  value       = module.tenant_001.storage
}

# === TENANT 002 OUTPUTS ===
output "tenant_002_summary" {
  description = "Summary of tenant-002 infrastructure"
  value       = module.tenant_002.tenant_summary
}

output "tenant_002_access" {
  description = "Access information for tenant-002"
  value       = module.tenant_002.access_info
}

output "tenant_002_networking" {
  description = "Networking configuration for tenant-002"
  value       = module.tenant_002.networking
}

output "tenant_002_storage" {
  description = "Storage configuration for tenant-002"
  value       = module.tenant_002.storage
}

# === SENSITIVE OUTPUTS ===
output "tenant_001_credentials" {
  description = "Admin credentials for tenant-001 (sensitive)"
  value = {
    database     = module.tenant_001.database_credentials
    applications = module.tenant_001.application_credentials
  }
  sensitive = true
}

output "tenant_002_credentials" {
  description = "Admin credentials for tenant-002 (sensitive)"
  value = {
    database     = module.tenant_002.database_credentials
    applications = module.tenant_002.application_credentials
  }
  sensitive = true
}

# === DEPLOYMENT SUMMARY ===
output "deployment_summary" {
  description = "Summary of all deployed tenants"
  value = {
    total_tenants = 2
    tenants = {
      "tenant-001" = {
        namespace        = module.tenant_001.namespace_name
        wordpress_domain = module.tenant_001.networking.wordpress_domain
        openwebui_domain = module.tenant_001.networking.openwebui_domain
        wordpress_ip     = module.tenant_001.networking.wordpress_loadbalancer_ip
        openwebui_ip     = module.tenant_001.networking.openwebui_loadbalancer_ip
        storage_total    = module.tenant_001.storage.storage_sizes.total_size
      }
      "tenant-002" = {
        namespace        = module.tenant_002.namespace_name
        wordpress_domain = module.tenant_002.networking.wordpress_domain
        openwebui_domain = module.tenant_002.networking.openwebui_domain
        wordpress_ip     = module.tenant_002.networking.wordpress_loadbalancer_ip
        openwebui_ip     = module.tenant_002.networking.openwebui_loadbalancer_ip
        storage_total    = module.tenant_002.storage.storage_sizes.total_size
      }
    }
    deployment_time = timestamp()
  }
}

# === NEXT STEPS ===
output "next_steps" {
  description = "Instructions for accessing and managing the tenants"
  value = <<-EOT
    
    🎉 Tenant infrastructure has been successfully provisioned!
    
    ## Access Information
    
    ### Tenant 001
    - WordPress: https://${module.tenant_001.networking.wordpress_domain}
    - OpenWebUI: https://${module.tenant_001.networking.openwebui_domain}
    - WordPress IP: ${module.tenant_001.networking.wordpress_loadbalancer_ip}
    - OpenWebUI IP: ${module.tenant_001.networking.openwebui_loadbalancer_ip}
    
    ### Tenant 002
    - WordPress: https://${module.tenant_002.networking.wordpress_domain}
    - OpenWebUI: https://${module.tenant_002.networking.openwebui_domain}
    - WordPress IP: ${module.tenant_002.networking.wordpress_loadbalancer_ip}
    - OpenWebUI IP: ${module.tenant_002.networking.openwebui_loadbalancer_ip}
    
    ## Next Steps
    
    1. **DNS Configuration**: Point your domains to the LoadBalancer IPs
    2. **Application Deployment**: Deploy WordPress and OpenWebUI using Helm charts
    3. **SSL Certificates**: Verify TLS certificates are issued by cert-manager
    4. **Admin Access**: Use the generated credentials to access admin interfaces
    5. **Monitoring**: Set up monitoring and alerting for the tenants
    
    ## Get Sensitive Data
    
    To retrieve admin passwords and database credentials:
    
    ```bash
    terraform output -json tenant_001_credentials
    terraform output -json tenant_002_credentials
    ```
    
    ## Manage Resources
    
    View namespace resources:
    ```bash
    kubectl get all -n ${module.tenant_001.namespace_name}
    kubectl get all -n ${module.tenant_002.namespace_name}
    ```
    
  EOT
}