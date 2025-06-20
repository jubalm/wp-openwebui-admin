# PostgreSQL cluster configuration variables
variable "cluster_name" {
  description = "Display name for the PostgreSQL cluster"
  type        = string
  default     = "authentik-postgres"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "location" {
  description = "Location for the PostgreSQL cluster"
  type        = string
  default     = "de/fra"
}

variable "instances" {
  description = "Number of PostgreSQL instances"
  type        = number
  default     = 1
}

variable "cores" {
  description = "Number of CPU cores per instance"
  type        = number
  default     = 2
}

variable "ram" {
  description = "RAM in MB per instance"
  type        = number
  default     = 4096
}

variable "storage_size" {
  description = "Storage size in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "HDD"
}

variable "datacenter_id" {
  description = "IONOS datacenter ID"
  type        = string
}

variable "lan_id" {
  description = "LAN ID for the PostgreSQL cluster"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR block allowed to connect to PostgreSQL"
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

variable "admin_username" {
  description = "Admin username for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for PostgreSQL"
  type        = string
  sensitive   = true
}