# Input variables for the example tenant with dedicated IONOS MariaDB cluster
# Note: Deploy infrastructure first using the infrastructure example to get datacenter_id

# IONOS Cloud authentication
variable "ionos_token" {
  description = "IONOS Cloud API token"
  type        = string
  sensitive   = true
}

# Infrastructure configuration (from infrastructure deployment)
variable "datacenter_id" {
  description = "IONOS datacenter ID (from infrastructure deployment)"
  type        = string
}

variable "lan_id" {
  description = "LAN ID for the MariaDB cluster"
  type        = string
  default     = "1"
}

variable "location" {
  description = "Location for the MariaDB cluster"
  type        = string
  default     = "de/fra"
}

# Tenant configuration
variable "tenant_id" {
  description = "Unique identifier for the tenant"
  type        = string
  default     = "example-tenant"
}

variable "wp_admin_email" {
  description = "WordPress admin email"
  type        = string
  default     = "admin@example-tenant.com"
}

# MariaDB cluster configuration for this tenant
variable "mariadb_version" {
  description = "MariaDB version"
  type        = string
  default     = "10.6"
}

variable "mariadb_instances" {
  description = "Number of MariaDB instances"
  type        = number
  default     = 1
}

variable "mariadb_cores" {
  description = "Number of CPU cores per MariaDB instance"
  type        = number
  default     = 2
}

variable "mariadb_ram" {
  description = "RAM in MB per MariaDB instance"
  type        = number
  default     = 4096
}

variable "mariadb_storage_size" {
  description = "Storage size in GB for MariaDB"
  type        = number
  default     = 20
}

variable "allowed_cidr" {
  description = "CIDR block allowed to connect to MariaDB"
  type        = string
  default     = "10.0.0.0/8"
}

variable "maintenance_day" {
  description = "Day of the week for maintenance"
  type        = string
  default     = "Sunday"
}

variable "maintenance_time" {
  description = "Time for maintenance (HH:MM:SS)"
  type        = string
  default     = "03:00:00"
}

variable "mariadb_admin_username" {
  description = "MariaDB admin username"
  type        = string
  sensitive   = true
}

variable "mariadb_admin_password" {
  description = "MariaDB admin password"
  type        = string
  sensitive   = true
}

# Authentik SSO configuration
variable "authentik_issuer_url" {
  description = "Authentik SSO issuer URL"
  type        = string
  default     = "https://authentik.platform.example.com"  # Update with actual Authentik URL
}

variable "authentik_client_secret" {
  description = "Authentik OIDC client secret for WordPress"
  type        = string
  sensitive   = true
}

# Resource allocation
variable "enable_resource_quota" {
  description = "Enable resource quota for the tenant"
  type        = bool
  default     = true
}

variable "cpu_limit" {
  description = "CPU limit for the tenant"
  type        = string
  default     = "1500m"
}

variable "memory_limit" {
  description = "Memory limit for the tenant"
  type        = string
  default     = "3Gi"
}

variable "storage_size" {
  description = "Storage size for the tenant"
  type        = string
  default     = "15Gi"
}

variable "cpu_requests" {
  description = "CPU requests for WordPress pods"
  type        = string
  default     = "250m"
}

variable "memory_requests" {
  description = "Memory requests for WordPress pods"
  type        = string
  default     = "512Mi"
}