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

variable "database_secret_name" {
  description = "Name of the database credentials secret"
  type        = string
}

variable "wp_admin_email" {
  description = "WordPress admin email address"
  type        = string
  
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.wp_admin_email))
    error_message = "WordPress admin email must be a valid email address."
  }
}

variable "wp_site_url" {
  description = "WordPress site URL (LoadBalancer IP or domain)"
  type        = string
}

variable "authentik_issuer_url" {
  description = "Authentik SSO issuer URL"
  type        = string
}

variable "authentik_client_id" {
  description = "Authentik OIDC client ID"
  type        = string
}

variable "authentik_client_secret" {
  description = "Authentik OIDC client secret"
  type        = string
  sensitive   = true
}

variable "storage_size" {
  description = "Size of persistent storage for WordPress files"
  type        = string
  default     = "10Gi"
}

variable "cpu_requests" {
  description = "CPU requests for WordPress pod"
  type        = string
  default     = "500m"
}

variable "memory_requests" {
  description = "Memory requests for WordPress pod"
  type        = string
  default     = "1Gi"
}