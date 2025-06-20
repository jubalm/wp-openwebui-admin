# Infrastructure variables

# IONOS Cloud configuration
variable "ionos_token" {
  description = "IONOS Cloud API token"
  type        = string
  sensitive   = true
}

variable "lan_id" {
  description = "LAN ID for the infrastructure"
  type        = string
  default     = "1"
}

variable "location" {
  description = "Location for the infrastructure"
  type        = string
  default     = "de/fra"
}

# PostgreSQL cluster configuration for Authentik
variable "postgres_cluster_name" {
  description = "Display name for the PostgreSQL cluster"
  type        = string
  default     = "authentik-postgres"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "postgres_instances" {
  description = "Number of PostgreSQL instances"
  type        = number
  default     = 1
}

variable "postgres_cores" {
  description = "Number of CPU cores per PostgreSQL instance"
  type        = number
  default     = 2
}

variable "postgres_ram" {
  description = "RAM in MB per PostgreSQL instance"
  type        = number
  default     = 4096
}

variable "postgres_storage_size" {
  description = "Storage size in GB for PostgreSQL"
  type        = number
  default     = 20
}

variable "postgres_storage_type" {
  description = "Storage type for PostgreSQL"
  type        = string
  default     = "HDD"
}

variable "allowed_cidr" {
  description = "CIDR block allowed to connect to services"
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

variable "postgres_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  sensitive   = true
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}