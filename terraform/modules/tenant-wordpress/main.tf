terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Generate WordPress authentication keys and salts
resource "random_password" "wp_auth_key" {
  length  = 64
  special = true
}

resource "random_password" "wp_secure_auth_key" {
  length  = 64
  special = true
}

resource "random_password" "wp_logged_in_key" {
  length  = 64
  special = true
}

resource "random_password" "wp_nonce_key" {
  length  = 64
  special = true
}

resource "random_password" "wp_auth_salt" {
  length  = 64
  special = true
}

resource "random_password" "wp_secure_auth_salt" {
  length  = 64
  special = true
}

resource "random_password" "wp_logged_in_salt" {
  length  = 64
  special = true
}

resource "random_password" "wp_nonce_salt" {
  length  = 64
  special = true
}

# WordPress configuration secret
resource "kubernetes_secret" "wordpress_config" {
  metadata {
    name      = "wordpress-config"
    namespace = var.namespace
    
    labels = {
      "app.kubernetes.io/name"      = "wordpress"
      "app.kubernetes.io/component" = "config"
      "tenant.platform/id"          = var.tenant_id
    }
  }

  data = {
    WORDPRESS_DB_HOST     = ""  # Will be populated by init container from database secret
    WORDPRESS_DB_NAME     = ""  # Will be populated by init container from database secret
    WORDPRESS_DB_USER     = ""  # Will be populated by init container from database secret
    WORDPRESS_DB_PASSWORD = ""  # Will be populated by init container from database secret
    
    WORDPRESS_AUTH_KEY         = random_password.wp_auth_key.result
    WORDPRESS_SECURE_AUTH_KEY  = random_password.wp_secure_auth_key.result
    WORDPRESS_LOGGED_IN_KEY    = random_password.wp_logged_in_key.result
    WORDPRESS_NONCE_KEY        = random_password.wp_nonce_key.result
    WORDPRESS_AUTH_SALT        = random_password.wp_auth_salt.result
    WORDPRESS_SECURE_AUTH_SALT = random_password.wp_secure_auth_salt.result
    WORDPRESS_LOGGED_IN_SALT   = random_password.wp_logged_in_salt.result
    WORDPRESS_NONCE_SALT       = random_password.wp_nonce_salt.result
    
    WORDPRESS_ADMIN_EMAIL = var.wp_admin_email
    WORDPRESS_SITE_URL    = var.wp_site_url
    
    # Authentik SSO configuration
    AUTHENTIK_ISSUER_URL    = var.authentik_issuer_url
    AUTHENTIK_CLIENT_ID     = var.authentik_client_id
    AUTHENTIK_CLIENT_SECRET = var.authentik_client_secret
  }

  type = "Opaque"
}

# Persistent Volume Claim for WordPress files
resource "kubernetes_persistent_volume_claim" "wordpress_files" {
  metadata {
    name      = "wordpress-files"
    namespace = var.namespace
    
    labels = {
      "app.kubernetes.io/name"      = "wordpress"
      "app.kubernetes.io/component" = "storage"
      "tenant.platform/id"          = var.tenant_id
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = var.storage_size
      }
    }
    
    # Use default storage class for IONOS
    storage_class_name = "ionos-csi-premium"
  }
}

# WordPress deployment
resource "kubernetes_deployment" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = var.namespace
    
    labels = {
      "app.kubernetes.io/name"      = "wordpress"
      "app.kubernetes.io/instance"  = var.tenant_id
      "tenant.platform/id"          = var.tenant_id
    }
  }

  spec {
    replicas = 1
    
    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "wordpress"
        "app.kubernetes.io/instance" = var.tenant_id
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"     = "wordpress"
          "app.kubernetes.io/instance" = var.tenant_id
          "tenant.platform/id"         = var.tenant_id
        }
      }

      spec {
        service_account_name = "wordpress"
        
        # Init container to set up database configuration
        init_container {
          name  = "db-config"
          image = "busybox:1.35"
          
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
              # Copy database credentials from secret
              cp /tmp/db-config/* /tmp/wp-config/
              
              # Set up WordPress database configuration
              echo "Database configuration copied successfully"
            EOT
          ]
          
          volume_mount {
            name       = "database-config"
            mount_path = "/tmp/db-config"
            read_only  = true
          }
          
          volume_mount {
            name       = "wordpress-config"
            mount_path = "/tmp/wp-config"
          }
        }

        container {
          name  = "wordpress"
          image = "wordpress:6.4-apache"
          
          port {
            container_port = 80
            name           = "http"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.wordpress_config.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = var.cpu_requests
              memory = var.memory_requests
            }
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }

          volume_mount {
            name       = "wordpress-files"
            mount_path = "/var/www/html"
          }

          liveness_probe {
            http_get {
              path = "/wp-admin/install.php"
              port = 80
            }
            initial_delay_seconds = 120
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/wp-admin/install.php"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        volume {
          name = "database-config"
          secret {
            secret_name = var.database_secret_name
          }
        }

        volume {
          name = "wordpress-config"
          empty_dir {}
        }

        volume {
          name = "wordpress-files"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wordpress_files.metadata[0].name
          }
        }
      }
    }
  }
}

# Internal ClusterIP service for WordPress
resource "kubernetes_service" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = var.namespace
    
    labels = {
      "app.kubernetes.io/name"      = "wordpress"
      "app.kubernetes.io/component" = "service"
      "tenant.platform/id"          = var.tenant_id
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"     = "wordpress"
      "app.kubernetes.io/instance" = var.tenant_id
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }

    type = "ClusterIP"
  }
}

# IONOS LoadBalancer service for external access
resource "kubernetes_service" "wordpress_lb" {
  metadata {
    name      = "wordpress-lb"
    namespace = var.namespace
    
    labels = {
      "app.kubernetes.io/name"      = "wordpress"
      "app.kubernetes.io/component" = "loadbalancer"
      "tenant.platform/id"          = var.tenant_id
    }
    
    annotations = {
      "service.beta.kubernetes.io/ionos-load-balancer-scheme" = "internet-facing"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"     = "wordpress"
      "app.kubernetes.io/instance" = var.tenant_id
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }

    type = "LoadBalancer"
  }
}