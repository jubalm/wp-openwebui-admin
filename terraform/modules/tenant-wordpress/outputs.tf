output "loadbalancer_ip" {
  description = "External IP address of the LoadBalancer"
  value       = kubernetes_service.wordpress_lb.status[0].load_balancer[0].ingress[0].ip
}

output "service_name" {
  description = "Name of the WordPress service"
  value       = kubernetes_service.wordpress_lb.metadata[0].name
}