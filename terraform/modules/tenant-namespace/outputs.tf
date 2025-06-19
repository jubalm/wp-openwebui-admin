# Tenant Namespace Module Outputs

output "namespace_name" {
  description = "Name of the created namespace"
  value       = kubernetes_namespace.tenant.metadata[0].name
}

output "service_account_name" {
  description = "Name of the tenant service account"
  value       = kubernetes_service_account.tenant.metadata[0].name
}

output "service_account_token_secret_name" {
  description = "Name of the service account token secret"
  value       = kubernetes_service_account.tenant.default_secret_name
}

output "namespace_labels" {
  description = "Labels applied to the namespace"
  value       = kubernetes_namespace.tenant.metadata[0].labels
}

output "resource_quota_name" {
  description = "Name of the resource quota"
  value       = kubernetes_resource_quota.tenant.metadata[0].name
}

output "limit_range_name" {
  description = "Name of the limit range"
  value       = kubernetes_limit_range.tenant.metadata[0].name
}

output "network_policy_name" {
  description = "Name of the network policy"
  value       = kubernetes_network_policy.tenant_isolation.metadata[0].name
}

output "role_name" {
  description = "Name of the RBAC role"
  value       = kubernetes_role.tenant.metadata[0].name
}

output "role_binding_name" {
  description = "Name of the RBAC role binding"
  value       = kubernetes_role_binding.tenant.metadata[0].name
}