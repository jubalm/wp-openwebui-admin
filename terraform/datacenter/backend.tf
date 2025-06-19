terraform {
  backend "s3" {
    key    = "primary-vdc/terraform.tfstate"
    bucket = "tf-primary-vdc-store"
    region = "eu-central-2"
    endpoints = {
      s3 = "https://s3-eu-central-2.ionoscloud.com"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }

  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13.2"
    }
  }

  required_version = ">= 1.5.0"
}

# Helm Provider for Kubernetes applications
# This allows managing Helm chart releases via Terraform
provider "helm" {
  kubernetes {
    config_path = "~/.kube/ionos-config" # Uses the same kubeconfig as the kubernetes provider
  }
}
