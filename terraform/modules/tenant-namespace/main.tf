# Tenant Namespace Module
# Creates Kubernetes namespace with RBAC and NetworkPolicies for tenant isolation

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

# Create tenant namespace
resource "kubernetes_namespace" "tenant" {
  metadata {
    name = var.namespace_name
    labels = {
      "tenant-id"    = var.tenant_id
      "managed-by"   = "terraform"
      "environment"  = var.environment
    }
    annotations = {
      "description" = "Namespace for tenant ${var.tenant_id}"
    }
  }
}

# Create service account for tenant applications
resource "kubernetes_service_account" "tenant" {
  metadata {
    name      = "${var.tenant_id}-service-account"
    namespace = kubernetes_namespace.tenant.metadata[0].name
    labels = {
      "tenant-id" = var.tenant_id
    }
  }
}

# Create RBAC role for tenant resources
resource "kubernetes_role" "tenant" {
  metadata {
    namespace = kubernetes_namespace.tenant.metadata[0].name
    name      = "${var.tenant_id}-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
    verbs      = ["get", "list", "watch"]
  }
}

# Bind role to service account
resource "kubernetes_role_binding" "tenant" {
  metadata {
    name      = "${var.tenant_id}-role-binding"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.tenant.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tenant.metadata[0].name
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
}

# Network policy for tenant isolation
resource "kubernetes_network_policy" "tenant_isolation" {
  metadata {
    name      = "${var.tenant_id}-isolation"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  spec {
    pod_selector {}

    policy_types = ["Ingress", "Egress"]

    # Allow ingress only from same namespace and ingress controllers
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = kubernetes_namespace.tenant.metadata[0].name
          }
        }
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "ingress-nginx"  # Allow ingress controller
          }
        }
      }
    }

    # Allow egress to same namespace, DNS, and external services
    egress {
      to {
        namespace_selector {
          match_labels = {
            name = kubernetes_namespace.tenant.metadata[0].name
          }
        }
      }
    }

    egress {
      to {
        namespace_selector {
          match_labels = {
            name = "kube-system"  # Allow DNS
          }
        }
      }
      ports {
        protocol = "UDP"
        port     = "53"
      }
    }

    # Allow external egress for application needs
    egress {
      to {}
      ports {
        protocol = "TCP"
        port     = "80"
      }
      ports {
        protocol = "TCP"
        port     = "443"
      }
    }
  }
}

# Resource quotas for tenant
resource "kubernetes_resource_quota" "tenant" {
  metadata {
    name      = "${var.tenant_id}-quota"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"       = var.cpu_requests
      "requests.memory"    = var.memory_requests
      "limits.cpu"         = var.cpu_limits
      "limits.memory"      = var.memory_limits
      "persistentvolumeclaims" = var.pvc_count
      "pods"               = var.pod_count
      "services"           = var.service_count
    }
  }
}

# Limit ranges for tenant pods
resource "kubernetes_limit_range" "tenant" {
  metadata {
    name      = "${var.tenant_id}-limits"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.default_cpu_limit
        memory = var.default_memory_limit
      }
      default_request = {
        cpu    = var.default_cpu_request
        memory = var.default_memory_request
      }
    }
  }
}