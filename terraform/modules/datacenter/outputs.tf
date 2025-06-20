output "datacenter_id" {
  description = "ID of the provisioned datacenter"
  value       = ionoscloud_datacenter.poc_primary_vdc.id
}

output "datacenter_name" {
  description = "Name of the provisioned datacenter"
  value       = ionoscloud_datacenter.poc_primary_vdc.name
}

output "datacenter_location" {
  description = "Location of the provisioned datacenter"
  value       = ionoscloud_datacenter.poc_primary_vdc.location
}
