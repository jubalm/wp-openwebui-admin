# Tenant Storage Module Variables

variable "tenant_id" {
  description = "Unique identifier for the tenant"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.tenant_id))
    error_message = "Tenant ID must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "namespace_name" {
  description = "Name of the Kubernetes namespace for the tenant"
  type        = string
}

# Storage Configuration
variable "storage_class_name" {
  description = "Name of the storage class to use for PVCs"
  type        = string
  default     = "ionos-csi-ssd"
}

variable "create_custom_storage_class" {
  description = "Create a custom storage class for the tenant"
  type        = bool
  default     = false
}

variable "storage_provisioner" {
  description = "Storage provisioner for custom storage class"
  type        = string
  default     = "csi.ionos.com"
}

variable "storage_parameters" {
  description = "Parameters for the storage class"
  type        = map(string)
  default = {
    "csi.storage.k8s.io/fstype" = "ext4"
    "type"                      = "SSD"
  }
}

# WordPress Storage Sizes
variable "wordpress_db_storage_size" {
  description = "Storage size for WordPress database"
  type        = string
  default     = "20Gi"
}

variable "wordpress_content_storage_size" {
  description = "Storage size for WordPress content and uploads"
  type        = string
  default     = "10Gi"
}

# OpenWebUI Storage Size
variable "openwebui_storage_size" {
  description = "Storage size for OpenWebUI data"
  type        = string
  default     = "5Gi"
}

# Database Configuration
variable "mysql_database" {
  description = "MySQL database name for WordPress"
  type        = string
  default     = "wordpress"
}

variable "mysql_user" {
  description = "MySQL user for WordPress"
  type        = string
  default     = "wordpress"
}

variable "mysql_root_password" {
  description = "MySQL root password (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQL user password (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

# Backup Configuration
variable "enable_backup_config" {
  description = "Enable backup configuration"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Cron schedule for backups"
  type        = string
  default     = "0 2 * * *"  # Daily at 2 AM
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "backup_storage_class" {
  description = "Storage class for backups"
  type        = string
  default     = "ionos-csi-hdd"
}