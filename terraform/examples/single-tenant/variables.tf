# Input variables for the example tenant with IONOS MariaDB cluster
# Note: Deploy infrastructure first using the infrastructure example to get these values

variable "mariadb_host" {
  description = "IONOS MariaDB cluster hostname (from infrastructure deployment)"
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