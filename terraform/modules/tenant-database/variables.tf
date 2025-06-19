variable "tenant_id" {
  description = "Unique identifier for the tenant"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.tenant_id))
    error_message = "Tenant ID must be a valid DNS label (lowercase letters, numbers, and hyphens only)."
  }
}

variable "namespace" {
  description = "Kubernetes namespace for the tenant"
  type        = string
}

variable "mariadb_host" {
  description = "IONOS MariaDB cluster hostname"
  type        = string
}

variable "mariadb_port" {
  description = "MariaDB port"
  type        = number
  default     = 3306
}

variable "mariadb_admin_user" {
  description = "MariaDB admin username"
  type        = string
  sensitive   = true
}

variable "mariadb_admin_password" {
  description = "MariaDB admin password"
  type        = string
  sensitive   = true
}