# Tenant Security Module
# Creates security policies, secrets, and access controls for tenant

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Pod Security Policy or Pod Security Standards
resource "kubernetes_config_map" "pod_security_config" {
  metadata {
    name      = "${var.tenant_id}-pod-security"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
      "component" = "security"
    }
  }

  data = {
    "pod-security.kubernetes.io/enforce" = var.pod_security_standard
    "pod-security.kubernetes.io/audit"   = var.pod_security_standard
    "pod-security.kubernetes.io/warn"    = var.pod_security_standard
  }
}

# Security context constraints for tenant applications
resource "kubernetes_config_map" "security_context" {
  metadata {
    name      = "${var.tenant_id}-security-context"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
    }
  }

  data = {
    "runAsNonRoot"             = "true"
    "runAsUser"                = "1000"
    "runAsGroup"               = "1000"
    "fsGroup"                  = "1000"
    "allowPrivilegeEscalation" = "false"
    "readOnlyRootFilesystem"   = "false"  # WordPress needs write access
    "seccompProfile"           = "RuntimeDefault"
  }
}

# Application secrets for WordPress
resource "kubernetes_secret" "wordpress_secrets" {
  metadata {
    name      = "${var.tenant_id}-wordpress-secrets"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
      "app"       = "wordpress"
    }
  }

  type = "Opaque"

  data = {
    # WordPress configuration
    wp_auth_key         = base64encode(var.wp_auth_key != null ? var.wp_auth_key : random_password.wp_auth_key.result)
    wp_secure_auth_key  = base64encode(var.wp_secure_auth_key != null ? var.wp_secure_auth_key : random_password.wp_secure_auth_key.result)
    wp_logged_in_key    = base64encode(var.wp_logged_in_key != null ? var.wp_logged_in_key : random_password.wp_logged_in_key.result)
    wp_nonce_key        = base64encode(var.wp_nonce_key != null ? var.wp_nonce_key : random_password.wp_nonce_key.result)
    wp_auth_salt        = base64encode(var.wp_auth_salt != null ? var.wp_auth_salt : random_password.wp_auth_salt.result)
    wp_secure_auth_salt = base64encode(var.wp_secure_auth_salt != null ? var.wp_secure_auth_salt : random_password.wp_secure_auth_salt.result)
    wp_logged_in_salt   = base64encode(var.wp_logged_in_salt != null ? var.wp_logged_in_salt : random_password.wp_logged_in_salt.result)
    wp_nonce_salt       = base64encode(var.wp_nonce_salt != null ? var.wp_nonce_salt : random_password.wp_nonce_salt.result)
    
    # Admin user
    wp_admin_user     = base64encode(var.wp_admin_user)
    wp_admin_password = base64encode(var.wp_admin_password != null ? var.wp_admin_password : random_password.wp_admin_password.result)
    wp_admin_email    = base64encode(var.wp_admin_email)
  }
}

# Application secrets for OpenWebUI
resource "kubernetes_secret" "openwebui_secrets" {
  metadata {
    name      = "${var.tenant_id}-openwebui-secrets"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
      "app"       = "openwebui"
    }
  }

  type = "Opaque"

  data = {
    # OpenWebUI JWT secret
    jwt_secret = base64encode(var.openwebui_jwt_secret != null ? var.openwebui_jwt_secret : random_password.openwebui_jwt.result)
    
    # Admin credentials
    admin_email    = base64encode(var.openwebui_admin_email)
    admin_password = base64encode(var.openwebui_admin_password != null ? var.openwebui_admin_password : random_password.openwebui_admin.result)
    
    # API keys if provided
    openai_api_key = base64encode(var.openai_api_key != null ? var.openai_api_key : "")
  }
}

# Generate random secrets
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

resource "random_password" "wp_admin_password" {
  length  = 16
  special = true
}

resource "random_password" "openwebui_jwt" {
  length  = 32
  special = true
}

resource "random_password" "openwebui_admin" {
  length  = 16
  special = true
}

# TLS certificate secret (placeholder for cert-manager integration)
resource "kubernetes_secret" "tls_certificate" {
  count = var.enable_tls ? 1 : 0

  metadata {
    name      = "${var.tenant_id}-tls-cert"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
    }
    annotations = {
      # Cert-manager annotations for automatic certificate generation
      "cert-manager.io/issuer"      = var.cert_manager_issuer
      "cert-manager.io/common-name" = var.wordpress_domain != null ? var.wordpress_domain : "${var.tenant_id}-wp.${var.base_domain}"
    }
  }

  type = "kubernetes.io/tls"

  # Placeholder data - cert-manager will populate this
  data = {
    "tls.crt" = base64encode("")
    "tls.key" = base64encode("")
  }
}

# Security scanning configuration
resource "kubernetes_config_map" "security_scan_config" {
  count = var.enable_security_scanning ? 1 : 0

  metadata {
    name      = "${var.tenant_id}-security-scan"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
    }
  }

  data = {
    scan_schedule     = var.security_scan_schedule
    scan_enabled      = "true"
    scan_critical     = "true"
    scan_high         = "true"
    scan_medium       = tostring(var.scan_medium_vulnerabilities)
    scan_low          = tostring(var.scan_low_vulnerabilities)
  }
}

# Monitoring and alerting configuration
resource "kubernetes_config_map" "monitoring_config" {
  metadata {
    name      = "${var.tenant_id}-monitoring"
    namespace = var.namespace_name
    labels = {
      "tenant-id" = var.tenant_id
    }
  }

  data = {
    prometheus_scrape = "true"
    metrics_port      = "9090"
    log_level         = var.log_level
    audit_enabled     = tostring(var.enable_audit_logging)
  }
}