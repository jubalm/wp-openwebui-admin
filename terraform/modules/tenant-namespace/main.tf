# Kubernetes namespace for tenant isolation
resource "kubernetes_namespace" "tenant" {
  metadata {
    name = "tenant-${var.tenant_id}"
    
    labels = {
      "app.kubernetes.io/name"       = "wordpress"
      "app.kubernetes.io/part-of"    = "wp-openwebui-platform"
      "tenant.platform/id"           = var.tenant_id
      "tenant.platform/type"         = "wordpress"
    }
  }
}

# ServiceAccount for WordPress deployment
resource "kubernetes_service_account" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = kubernetes_namespace.tenant.metadata[0].name
    
    labels = {
      "app.kubernetes.io/name"       = "wordpress"
      "app.kubernetes.io/component"  = "serviceaccount"
      "tenant.platform/id"           = var.tenant_id
    }
  }
}

# Role for WordPress deployment with minimal permissions
resource "kubernetes_role" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "persistentvolumeclaims", "secrets", "configmaps"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# RoleBinding to associate ServiceAccount with Role
resource "kubernetes_role_binding" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.wordpress.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.wordpress.metadata[0].name
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
}

# Optional ResourceQuota for resource management
resource "kubernetes_resource_quota" "tenant" {
  count = var.enable_resource_quota ? 1 : 0
  
  metadata {
    name      = "tenant-quota"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.cpu_limit
      "requests.memory" = var.memory_limit
      "requests.storage" = var.storage_limit
      "persistentvolumeclaims" = "5"
      "services" = "5"
      "secrets" = "10"
      "configmaps" = "10"
    }
  }
}