# Tenant Namespace Module Variables

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
  default     = null
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Resource quotas
variable "cpu_requests" {
  description = "Total CPU requests allowed for the tenant"
  type        = string
  default     = "2"
}

variable "memory_requests" {
  description = "Total memory requests allowed for the tenant"
  type        = string
  default     = "4Gi"
}

variable "cpu_limits" {
  description = "Total CPU limits allowed for the tenant"
  type        = string
  default     = "4"
}

variable "memory_limits" {
  description = "Total memory limits allowed for the tenant"
  type        = string
  default     = "8Gi"
}

variable "pvc_count" {
  description = "Number of persistent volume claims allowed"
  type        = string
  default     = "10"
}

variable "pod_count" {
  description = "Number of pods allowed"
  type        = string
  default     = "20"
}

variable "service_count" {
  description = "Number of services allowed"
  type        = string
  default     = "10"
}

# Default resource limits for individual containers
variable "default_cpu_limit" {
  description = "Default CPU limit for containers"
  type        = string
  default     = "500m"
}

variable "default_memory_limit" {
  description = "Default memory limit for containers"
  type        = string
  default     = "1Gi"
}

variable "default_cpu_request" {
  description = "Default CPU request for containers"
  type        = string
  default     = "100m"
}

variable "default_memory_request" {
  description = "Default memory request for containers"
  type        = string
  default     = "256Mi"
}