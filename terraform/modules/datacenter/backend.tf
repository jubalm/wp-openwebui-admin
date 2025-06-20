terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
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
