output "namespace_name" {
  description = "Name of the created namespace"
  value       = kubernetes_namespace.tenant.metadata[0].name
}

output "service_account_name" {
  description = "Name of the created ServiceAccount"
  value       = kubernetes_service_account.wordpress.metadata[0].name
}