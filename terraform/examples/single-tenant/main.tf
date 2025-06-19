# Single Tenant Example Configuration
# Demonstrates how to provision infrastructure for a single tenant

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  # Configuration will be provided via environment variables or kubeconfig
  # For IONOS Managed Kubernetes, use the kubeconfig from IONOS Cloud Console
}

# Provision infrastructure for tenant-001
module "tenant_001" {
  source = "../../modules/tenant"

  # Basic tenant configuration
  tenant_id   = "tenant-001"
  environment = "production"

  # Admin credentials
  wp_admin_email         = "admin@tenant001.example.com"
  openwebui_admin_email  = "admin@tenant001.example.com"

  # Domain configuration
  base_domain       = "example.com"
  wordpress_domain  = "tenant001-wp.example.com"
  openwebui_domain  = "tenant001-ui.example.com"

  # Resource quotas (suitable for small-medium tenant)
  cpu_requests    = "1"      # 1 CPU core
  memory_requests = "2Gi"    # 2GB RAM
  cpu_limits      = "2"      # 2 CPU cores
  memory_limits   = "4Gi"    # 4GB RAM

  # Storage configuration
  storage_class_name                = "ionos-csi-ssd"
  wordpress_db_storage_size         = "10Gi"
  wordpress_content_storage_size    = "5Gi"
  openwebui_storage_size           = "2Gi"

  # Security configuration
  pod_security_standard = "restricted"
  enable_tls           = true
  cert_manager_issuer  = "letsencrypt-prod"

  # Enable security features
  enable_security_scanning = true
  enable_audit_logging    = true
  log_level              = "INFO"

  # Backup configuration
  enable_backup_config  = true
  backup_schedule       = "0 2 * * *"  # Daily at 2 AM
  backup_retention_days = 30
}

# Example of provisioning a second tenant with different resources
module "tenant_002" {
  source = "../../modules/tenant"

  # Basic tenant configuration
  tenant_id   = "tenant-002"
  environment = "production"

  # Admin credentials
  wp_admin_email         = "admin@tenant002.example.com"
  openwebui_admin_email  = "admin@tenant002.example.com"

  # Domain configuration
  base_domain       = "example.com"
  wordpress_domain  = "tenant002-wp.example.com"
  openwebui_domain  = "tenant002-ui.example.com"

  # Higher resource quotas (suitable for larger tenant)
  cpu_requests    = "2"      # 2 CPU cores
  memory_requests = "4Gi"    # 4GB RAM
  cpu_limits      = "4"      # 4 CPU cores
  memory_limits   = "8Gi"    # 8GB RAM

  # Larger storage configuration
  storage_class_name                = "ionos-csi-ssd"
  wordpress_db_storage_size         = "20Gi"
  wordpress_content_storage_size    = "10Gi"
  openwebui_storage_size           = "5Gi"

  # Security configuration
  pod_security_standard = "restricted"
  enable_tls           = true
  cert_manager_issuer  = "letsencrypt-prod"

  # Enable additional security features
  enable_security_scanning     = true
  scan_medium_vulnerabilities  = true
  scan_low_vulnerabilities     = true
  enable_audit_logging        = true
  log_level                   = "DEBUG"  # More verbose logging

  # More frequent backups for important tenant
  enable_backup_config  = true
  backup_schedule       = "0 */6 * * *"  # Every 6 hours
  backup_retention_days = 90
}