output "namespace_name" {
  description = "Name of the created namespace"
  value       = module.namespace.namespace_name
}

output "database_name" {
  description = "Name of the created database"
  value       = module.database.database_name
}

output "wordpress_url" {
  description = "URL to access WordPress (LoadBalancer IP)"
  value       = "http://${module.wordpress.loadbalancer_ip}"
}

output "loadbalancer_ip" {
  description = "External IP address of the LoadBalancer"
  value       = module.wordpress.loadbalancer_ip
}