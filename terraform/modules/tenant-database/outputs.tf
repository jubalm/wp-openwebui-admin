output "database_name" {
  description = "Name of the created database"
  value       = local.database_name
}

output "database_user" {
  description = "Username for the database"
  value       = local.database_user
}

output "secret_name" {
  description = "Name of the Kubernetes secret containing database credentials"
  value       = kubernetes_secret.database_credentials.metadata[0].name
}