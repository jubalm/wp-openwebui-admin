provider "ionoscloud" {
  token = var.ionos_token
}

resource "ionoscloud_datacenter" "poc_primary_vdc" {
  name     = "PoC Primary VDC"
  location = "de/txl"
}
