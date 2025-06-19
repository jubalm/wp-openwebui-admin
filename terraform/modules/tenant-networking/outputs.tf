# Tenant Networking Module Outputs

output "wordpress_loadbalancer_ip" {
  description = "External IP address of the WordPress LoadBalancer"
  value       = try(kubernetes_service.wordpress_loadbalancer.status[0].load_balancer[0].ingress[0].ip, "pending")
}

output "openwebui_loadbalancer_ip" {
  description = "External IP address of the OpenWebUI LoadBalancer"
  value       = try(kubernetes_service.openwebui_loadbalancer.status[0].load_balancer[0].ingress[0].ip, "pending")
}

output "wordpress_service_name" {
  description = "Name of the WordPress LoadBalancer service"
  value       = kubernetes_service.wordpress_loadbalancer.metadata[0].name
}

output "openwebui_service_name" {
  description = "Name of the OpenWebUI LoadBalancer service"
  value       = kubernetes_service.openwebui_loadbalancer.metadata[0].name
}

output "wordpress_internal_service_name" {
  description = "Name of the WordPress internal service"
  value       = kubernetes_service.wordpress_internal.metadata[0].name
}

output "openwebui_internal_service_name" {
  description = "Name of the OpenWebUI internal service"
  value       = kubernetes_service.openwebui_internal.metadata[0].name
}

output "wordpress_internal_fqdn" {
  description = "Internal FQDN for WordPress service"
  value       = "${kubernetes_service.wordpress_internal.metadata[0].name}.${var.namespace_name}.svc.cluster.local"
}

output "openwebui_internal_fqdn" {
  description = "Internal FQDN for OpenWebUI service"
  value       = "${kubernetes_service.openwebui_internal.metadata[0].name}.${var.namespace_name}.svc.cluster.local"
}

output "wordpress_domain" {
  description = "Domain name for WordPress"
  value       = var.wordpress_domain != null ? var.wordpress_domain : "${var.tenant_id}-wp.${var.base_domain}"
}

output "openwebui_domain" {
  description = "Domain name for OpenWebUI"
  value       = var.openwebui_domain != null ? var.openwebui_domain : "${var.tenant_id}-ui.${var.base_domain}"
}

output "dns_config_name" {
  description = "Name of the DNS configuration ConfigMap"
  value       = var.enable_custom_dns ? kubernetes_config_map.dns_config[0].metadata[0].name : null
}

output "network_policy_name" {
  description = "Name of the external access network policy"
  value       = kubernetes_network_policy.external_access.metadata[0].name
}