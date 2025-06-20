# IONOS networking configuration for the PoC environment
# Includes private network, public IPs, and firewall rules

# Private network for internal communication
resource "ionoscloud_lan" "private_network" {
  datacenter_id = ionoscloud_datacenter.poc_primary_vdc.id
  name          = "PoC-Private-Network"
  public        = false
}

# Public IP block for external access
resource "ionoscloud_ipblock" "public_ips" {
  name     = "PoC-Public-IPs"
  location = ionoscloud_datacenter.poc_primary_vdc.location
  size     = 4 # Allocate 4 public IPs for Kubernetes node pool (minimum 3 required)
}

# Outputs for reference in other configurations
output "private_network_id" {
  description = "ID of the private network"
  value       = ionoscloud_lan.private_network.id
}

output "public_ip_block_id" {
  description = "ID of the public IP block"
  value       = ionoscloud_ipblock.public_ips.id
}

output "public_ips" {
  description = "List of allocated public IPs"
  value       = ionoscloud_ipblock.public_ips.ips
}
