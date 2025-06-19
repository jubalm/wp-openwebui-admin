# Infrastructure variables

# IONOS Cloud configuration
variable "ionos_token" {
  description = "IONOS Cloud API token"
  type        = string
  sensitive   = true
}

variable "datacenter_id" {
  description = "IONOS datacenter ID"
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

# MariaDB cluster configuration
variable "cluster_name" {
  description = "Display name for the MariaDB cluster"
  type        = string
  default     = "wp-openwebui-mariadb"
}

variable "mariadb_version" {
  description = "MariaDB version"
  type        = string
  default     = "10.6"
}

variable "instances" {
  description = "Number of MariaDB instances"
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