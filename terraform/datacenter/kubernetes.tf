# IONOS Kubernetes Service (IKS) configuration
# Sets up a managed Kubernetes cluster and associated node pools

# Kubernetes provider configuration
# Note: This requires ionosctl to be installed and configured before terraform runs
# The GitHub Actions workflow handles this in the "Install IONOS CLI" step
provider "kubernetes" {
  config_path = "~/.kube/ionos-config"
}

# Main Kubernetes cluster
resource "ionoscloud_k8s_cluster" "poc_cluster" {
  name        = "poc-k8s-cluster-${random_id.cluster_suffix.hex}"
  k8s_version = "1.30.13" # Updated to supported version from available: 1.29.4 - 1.32.5

  # Maintenance window for automatic updates
  maintenance_window {
    day_of_the_week = "Sunday"
    time            = "04:00:00Z"
  }

  # Allow API access from specified IPs (update as needed)
  api_subnet_allow_list = ["0.0.0.0/0"] # For PoC; restrict in production
}

# Random suffix for unique cluster naming and recovery identification
resource "random_id" "cluster_suffix" {
  byte_length = 4
}

# Default node pool for the cluster
resource "ionoscloud_k8s_node_pool" "default_pool" {
  name           = "default-nodepool"
  k8s_cluster_id = ionoscloud_k8s_cluster.poc_cluster.id
  k8s_version    = ionoscloud_k8s_cluster.poc_cluster.k8s_version
  datacenter_id  = ionoscloud_datacenter.poc_primary_vdc.id

  # Node configuration
  availability_zone = "AUTO"
  node_count        = 2
  cpu_family        = "INTEL_XEON" # Correct CPU family for us/las location
  cores_count       = 2
  ram_size          = 4096  # In MB (4 GB)
  storage_type      = "SSD" # Using SSD for better performance
  storage_size      = 100   # In GB

  # Public IPs - use our allocated IP block
  public_ips = ionoscloud_ipblock.public_ips.ips

  # Maintenance window for node updates
  maintenance_window {
    day_of_the_week = "Sunday"
    time            = "05:00:00Z"
  }

  # Labels for node selection in Kubernetes and recovery tracking
  labels = {
    "nodepool"       = "default"
    "environment"    = "poc"
    "terraform"      = "managed"
    "project"        = "ionos-poc"
    "cluster-suffix" = random_id.cluster_suffix.hex
  }
}

# Outputs for Kubernetes configuration
output "k8s_cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = ionoscloud_k8s_cluster.poc_cluster.id
}

output "k8s_cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = ionoscloud_k8s_cluster.poc_cluster.name
}

output "k8s_version" {
  description = "Kubernetes version deployed"
  value       = ionoscloud_k8s_cluster.poc_cluster.k8s_version
}

output "kubeconfig_command" {
  description = "Command to get the kubeconfig file"
  value       = "ionosctl k8s kubeconfig get --cluster-id ${ionoscloud_k8s_cluster.poc_cluster.id}"
}

output "cluster_suffix" {
  description = "Random suffix used for cluster naming (helps with recovery)"
  value       = random_id.cluster_suffix.hex
}
