variable "tenant_id" {
  description = "Unique identifier for the tenant"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.tenant_id))
    error_message = "Tenant ID must be a valid DNS label (lowercase letters, numbers, and hyphens only)."
  }
}

variable "enable_resource_quota" {
  description = "Enable ResourceQuota for the namespace"
  type        = bool
  default     = false
}

variable "cpu_limit" {
  description = "CPU limit for the namespace"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for the namespace"
  type        = string
  default     = "2Gi"
}

variable "storage_limit" {
  description = "Storage limit for the namespace"
  type        = string
  default     = "5Gi"
}