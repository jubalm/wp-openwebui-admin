# Tenant Security Module Variables

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

# Pod Security Standards
variable "pod_security_standard" {
  description = "Pod Security Standard level (privileged, baseline, restricted)"
  type        = string
  default     = "restricted"
  validation {
    condition     = contains(["privileged", "baseline", "restricted"], var.pod_security_standard)
    error_message = "Pod security standard must be one of: privileged, baseline, restricted."
  }
}

# WordPress Security
variable "wp_admin_user" {
  description = "WordPress admin username"
  type        = string
  default     = "admin"
}

variable "wp_admin_email" {
  description = "WordPress admin email"
  type        = string
}

variable "wp_admin_password" {
  description = "WordPress admin password (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

# WordPress authentication keys and salts
variable "wp_auth_key" {
  description = "WordPress AUTH_KEY (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "wp_secure_auth_key" {
  description = "WordPress SECURE_AUTH_KEY (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "wp_logged_in_key" {
  description = "WordPress LOGGED_IN_KEY (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "wp_nonce_key" {
  description = "WordPress NONCE_KEY (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "wp_auth_salt" {
  description = "WordPress AUTH_SALT (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "wp_secure_auth_salt" {
  description = "WordPress SECURE_AUTH_SALT (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "wp_logged_in_salt" {
  description = "WordPress LOGGED_IN_SALT (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "wp_nonce_salt" {
  description = "WordPress NONCE_SALT (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

# OpenWebUI Security
variable "openwebui_admin_email" {
  description = "OpenWebUI admin email"
  type        = string
}

variable "openwebui_admin_password" {
  description = "OpenWebUI admin password (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "openwebui_jwt_secret" {
  description = "OpenWebUI JWT secret (if not set, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "openai_api_key" {
  description = "OpenAI API key for OpenWebUI (optional)"
  type        = string
  default     = null
  sensitive   = true
}

# TLS Configuration
variable "enable_tls" {
  description = "Enable TLS certificate management"
  type        = bool
  default     = true
}

variable "cert_manager_issuer" {
  description = "Cert-manager issuer for TLS certificates"
  type        = string
  default     = "letsencrypt-prod"
}

variable "base_domain" {
  description = "Base domain for tenant services"
  type        = string
  default     = "example.com"
}

variable "wordpress_domain" {
  description = "Custom domain for WordPress"
  type        = string
  default     = null
}

# Security Scanning
variable "enable_security_scanning" {
  description = "Enable security vulnerability scanning"
  type        = bool
  default     = true
}

variable "security_scan_schedule" {
  description = "Cron schedule for security scans"
  type        = string
  default     = "0 3 * * *"  # Daily at 3 AM
}

variable "scan_medium_vulnerabilities" {
  description = "Include medium severity vulnerabilities in scans"
  type        = bool
  default     = true
}

variable "scan_low_vulnerabilities" {
  description = "Include low severity vulnerabilities in scans"
  type        = bool
  default     = false
}

# Monitoring and Logging
variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "INFO"
  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.log_level)
    error_message = "Log level must be one of: DEBUG, INFO, WARN, ERROR."
  }
}

variable "enable_audit_logging" {
  description = "Enable audit logging"
  type        = bool
  default     = true
}