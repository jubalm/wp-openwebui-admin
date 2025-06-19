# Tenant Networking Module
# Creates IONOS LoadBalancer and networking resources for tenant access

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

# LoadBalancer service for WordPress
resource "kubernetes_service" "wordpress_loadbalancer" {
  metadata {
    name      = "${var.tenant_id}-wordpress-lb"
    namespace = var.namespace_name
    labels = {
      "tenant-id"   = var.tenant_id
      "app"         = "wordpress"
      "service"     = "loadbalancer"
    }
    annotations = {
      "service.beta.kubernetes.io/ionos-load-balancer-type" = "public"
      "service.beta.kubernetes.io/ionos-load-balancer-forwarding-rule" = "http"
      # Enable session affinity for WordPress
      "service.beta.kubernetes.io/ionos-load-balancer-session-affinity" = "ClientIP"
    }
  }

  spec {
    type = "LoadBalancer"
    
    selector = {
      "tenant-id" = var.tenant_id
      "app"       = "wordpress"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "80"
      protocol    = "TCP"
    }

    port {
      name        = "https"
      port        = 443
      target_port = "443"
      protocol    = "TCP"
    }

    # Request specific external IP if provided
    dynamic "load_balancer_ip" {
      for_each = var.wordpress_external_ip != null ? [var.wordpress_external_ip] : []
      content {
        load_balancer_ip = load_balancer_ip.value
      }
    }
  }
}

# LoadBalancer service for OpenWebUI
resource "kubernetes_service" "openwebui_loadbalancer" {
  metadata {
    name      = "${var.tenant_id}-openwebui-lb"
    namespace = var.namespace_name
    labels = {
      "tenant-id"   = var.tenant_id
      "app"         = "openwebui"
      "service"     = "loadbalancer"
    }
    annotations = {
      "service.beta.kubernetes.io/ionos-load-balancer-type" = "public"
      "service.beta.kubernetes.io/ionos-load-balancer-forwarding-rule" = "http"
    }
  }

  spec {
    type = "LoadBalancer"
    
    selector = {
      "tenant-id" = var.tenant_id
      "app"       = "openwebui"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "8080"
      protocol    = "TCP"
    }

    port {
      name        = "https"
      port        = 443
      target_port = "8080"
      protocol    = "TCP"
    }

    # Request specific external IP if provided
    dynamic "load_balancer_ip" {
      for_each = var.openwebui_external_ip != null ? [var.openwebui_external_ip] : []
      content {
        load_balancer_ip = load_balancer_ip.value
      }
    }
  }
}

# Internal service for WordPress (for inter-service communication)
resource "kubernetes_service" "wordpress_internal" {
  metadata {
    name      = "${var.tenant_id}-wordpress-internal"
    namespace = var.namespace_name
    labels = {
      "tenant-id"   = var.tenant_id
      "app"         = "wordpress"
      "service"     = "internal"
    }
  }

  spec {
    type = "ClusterIP"
    
    selector = {
      "tenant-id" = var.tenant_id
      "app"       = "wordpress"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "80"
      protocol    = "TCP"
    }
  }
}

# Internal service for OpenWebUI (for inter-service communication)
resource "kubernetes_service" "openwebui_internal" {
  metadata {
    name      = "${var.tenant_id}-openwebui-internal"
    namespace = var.namespace_name
    labels = {
      "tenant-id"   = var.tenant_id
      "app"         = "openwebui"
      "service"     = "internal"
    }
  }

  spec {
    type = "ClusterIP"
    
    selector = {
      "tenant-id" = var.tenant_id
      "app"       = "openwebui"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = "8080"
      protocol    = "TCP"
    }
  }
}

# ConfigMap for tenant DNS configuration
resource "kubernetes_config_map" "dns_config" {
  count = var.enable_custom_dns ? 1 : 0

  metadata {
    name      = "${var.tenant_id}-dns-config"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
    }
  }

  data = {
    "wordpress_domain"   = var.wordpress_domain != null ? var.wordpress_domain : "${var.tenant_id}-wp.${var.base_domain}"
    "openwebui_domain"   = var.openwebui_domain != null ? var.openwebui_domain : "${var.tenant_id}-ui.${var.base_domain}"
    "internal_wordpress" = "${var.tenant_id}-wordpress-internal.${var.namespace_name}.svc.cluster.local"
    "internal_openwebui" = "${var.tenant_id}-openwebui-internal.${var.namespace_name}.svc.cluster.local"
  }
}

# Network policy for external access
resource "kubernetes_network_policy" "external_access" {
  metadata {
    name      = "${var.tenant_id}-external-access"
    namespace = var.namespace_name
  }

  spec {
    pod_selector {
      match_labels = {
        "tenant-id" = var.tenant_id
      }
    }

    policy_types = ["Ingress"]

    # Allow ingress from LoadBalancer
    ingress {
      from {
        # Allow from anywhere for LoadBalancer traffic
      }
      ports {
        protocol = "TCP"
        port     = "80"
      }
      ports {
        protocol = "TCP"
        port     = "443"
      }
      ports {
        protocol = "TCP"
        port     = "8080"
      }
    }
  }
}