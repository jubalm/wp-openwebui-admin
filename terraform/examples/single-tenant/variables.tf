# Input variables for the example tenant

variable "mariadb_host" {
  description = "IONOS MariaDB cluster hostname"
  type        = string
  default     = "mariadb-cluster.example.com"  # Update with actual IONOS MariaDB endpoint
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