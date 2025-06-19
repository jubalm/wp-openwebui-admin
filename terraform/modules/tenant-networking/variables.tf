# Tenant Networking Module Variables

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

# LoadBalancer IPs
variable "wordpress_external_ip" {
  description = "Specific external IP address for WordPress LoadBalancer (optional)"
  type        = string
  default     = null
}

variable "openwebui_external_ip" {
  description = "Specific external IP address for OpenWebUI LoadBalancer (optional)"
  type        = string
  default     = null
}

# DNS Configuration
variable "enable_custom_dns" {
  description = "Enable custom DNS configuration"
  type        = bool
  default     = true
}

variable "base_domain" {
  description = "Base domain for tenant subdomains"
  type        = string
  default     = "example.com"
}

variable "wordpress_domain" {
  description = "Custom domain for WordPress (optional, defaults to {tenant_id}-wp.{base_domain})"
  type        = string
  default     = null
}

variable "openwebui_domain" {
  description = "Custom domain for OpenWebUI (optional, defaults to {tenant_id}-ui.{base_domain})"
  type        = string
  default     = null
}

# LoadBalancer Configuration
variable "enable_session_affinity" {
  description = "Enable session affinity for WordPress LoadBalancer"
  type        = bool
  default     = true
}

variable "loadbalancer_annotations" {
  description = "Additional annotations for LoadBalancer services"
  type        = map(string)
  default     = {}
}