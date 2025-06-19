# IONOS Proof of Concept

A proof-of-concept deployment demonstrating modern cloud infrastructure and AI-powered content creation workflows on IONOS Cloud. This project specifically aims to **showcase the capabilities of the IONOS cloud platform** for hosting a scalable and automated multi-tenant solution.

## 🎯 Purpose

This PoC explores and aims to demonstrate:

- **IONOS Cloud Capabilities:** Highlighting IONOS Managed Kubernetes orchestration, infrastructure automation, and application hosting for a multi-tenant SaaS offering.
- **Multi-Tenancy:** Securely hosting multiple tenants (starting with a single tenant for the PoC), each with their own isolated WordPress instance (with official MCP plugin) and user accounts in a shared OpenWebUI instance managed via Authentik SSO.
- **Kubernetes deployment** on IONOS Cloud, leveraging IONOS Managed Kubernetes.
- **Infrastructure as Code** with Terraform for automated provisioning of all necessary IONOS resources (Kubernetes, networking, storage).
- **CI/CD automation** with GitHub Actions for streamlining development and deployment processes.
- **Automated Application Deployment:** Using Helm charts to deploy WordPress and OpenWebUI into the IONOS Kubernetes environment.
- **AI-powered content creation** with OpenWebUI, integrated with WordPress via the official MCP plugin.

## 🏗️ Project Structure

The project is organized as follows:

```
.
├── charts/                 # Helm charts for Kubernetes deployment
│   ├── wordpress-tenant/   # WordPress with MCP plugin for tenants
│   ├── openwebui/         # Shared OpenWebUI instance
│   └── shared-services/   # Shared infrastructure (Authentik, databases)
├── docker/                # Docker configurations and custom images
│   └── wordpress/         # Custom WordPress Docker image with automation
├── docs/                  # Project documentation and guides
│   ├── kb/                # Knowledgebase, learnings, external resources
│   ├── helm-deployment-guide.md  # Kubernetes deployment guide
│   └── tenant-onboarding.md      # Tenant onboarding process
├── scripts/               # Simplified automation scripts
│   ├── setup.sh           # Complete PoC setup
│   ├── test.sh            # Comprehensive testing
│   └── cleanup.sh         # Environment cleanup
├── values/                # Helm chart configuration examples
│   └── examples/          # Example tenant and service configurations
├── docker-compose.yml     # Multi-service orchestration (local development)
├── .env.example           # Environment configuration template
└── README.md              # This file
```

## ✨ Key Features (PoC Scope)

- **IONOS Secure Cloud Management:** Demonstrates IONOS Managed Kubernetes, networking (LoadBalancer for IP exposure), and storage solutions with a focus on security and scalability.
- **Multi-Tenant Architecture:** Implements a comprehensive tenant isolation strategy for securely hosting multiple tenants within the same infrastructure. The strategy uses Kubernetes namespaces with strict security controls for the PoC, with a clear migration path to dedicated clusters for production scaling. Detailed analysis and implementation guidance is provided in the [Tenant Isolation Strategy](docs/kb/tenant-isolation-strategy.md) document.
- **Automated Infrastructure Provisioning:** Using Terraform to create reusable modules for tenant infrastructure on IONOS.
- **Automated Application Deployment:** Customizable Helm charts for deploying WordPress (with MCP) and OpenWebUI into IONOS Managed Kubernetes with full multi-tenant support.
- **Core Application Stack per Tenant:** Dedicated WordPress (with MCP plugin) instances and user accounts in a shared OpenWebUI instance with Authentik SSO integration.
- **Data Persistence:** Strategy for persistent storage for WordPress and OpenWebUI using IONOS storage solutions.
- **🎯 PoC Implementation Complete**: Full working integration with CRUD operations validated

### Demonstrated Capabilities

- ✅ **WordPress Deployment**: Local WordPress instance with MariaDB database
- ✅ **Official WordPress MCP Plugin**: Automattic's official MCP plugin with standardized protocol
- ✅ **OpenWebUI Integration**: https://github.com/open-webui/open-webui
- ✅ **Docker Orchestration**: Complete containerized environment
- ✅ **MariaDB Compatibility**: Optimized for IONOS Cloud deployment
- ✅ **Single Sign-On (SSO)**: Authentik-based authentication for unified user management
- ✅ **OpenID Connect Integration**: Secure OAuth2/OIDC authentication for WordPress and OpenWebUI
- ✅ **Centralized User Management**: Single identity provider for all services
- ✅ **Documentation**: Complete setup and integration guides including SSO configuration
- ✅ **Automation**: Scripts for setup, testing, and cleanup

## 🚀 Getting Started

### Quick Start (PoC Demo)

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/jubalm/wp-openwebui-admin.git
   cd wp-openwebui-admin
   ```

2. **Install Dependencies:**
   Ensure you have Node.js and npm installed. Run:

   ```bash
   npm install
   ```

3. **Run the Application:**
   Start the development server:

   ```bash
   ./scripts/test.sh  # Comprehensive testing of all components
   ```

4. **Access Services:**
   - **WordPress**: http://localhost:8080
   - **OpenWebUI**: http://localhost:3000
   - **Authentik (SSO)**: http://localhost:9000

### Prerequisites

- **Docker & Docker Compose**: [Installation Guide](https://docs.docker.com/get-docker/)
- **Git**: For cloning the repository
- **curl**: For testing API endpoints

### For Kubernetes Deployment

- **Kubernetes cluster**: 1.24+ (IONOS Managed Kubernetes recommended)
- **Helm**: 3.8+ for application deployment
- **kubectl**: Configured for your cluster
- **Persistent Volume support**: For data persistence
- **Ingress Controller**: (optional) For external access

## 🚢 Kubernetes Deployment

### Quick Start with Helm Charts

Deploy the complete multi-tenant platform to Kubernetes:

```bash
# 1. Deploy shared services (one-time setup)
helm install shared-services ./charts/shared-services \
  --namespace shared-services \
  --create-namespace \
  -f values/examples/shared-services.yaml

# 2. Deploy a tenant
helm install tenant-acme ./charts/wordpress-tenant \
  --namespace tenant-acme \
  --create-namespace \
  -f values/examples/tenant-acme.yaml

# 3. Access your deployment
kubectl get ingress -A
```

### Production Deployment

For production IONOS deployment with LoadBalancer:

```bash
# Configure IONOS-specific values
helm install tenant-prod ./charts/wordpress-tenant \
  --namespace tenant-prod \
  --create-namespace \
  --set loadBalancer.enabled=true \
  --set loadBalancer.loadBalancerIP="YOUR_IONOS_IP" \
  -f values/production/tenant-prod.yaml
```

See [Helm Deployment Guide](docs/helm-deployment-guide.md) for detailed instructions.

## 📚 Documentation

### Local Development
- **[Setup Guide](docs/setup-guide.md)**: Comprehensive installation and configuration guide
- **[Automated SSO Guide](docs/automated-sso-guide.md)**: Complete Single Sign-On configuration with Authentik
- **[Scripts Documentation](scripts/README.md)**: Helper scripts usage guide

### Kubernetes Deployment
- **[Helm Deployment Guide](docs/helm-deployment-guide.md)**: Kubernetes deployment with Helm charts
- **[Tenant Onboarding](docs/tenant-onboarding.md)**: Step-by-step tenant onboarding process
- **[Tenant Isolation Strategy](docs/kb/tenant-isolation-strategy.md)**: Multi-tenant architecture and security

## Contributing

We welcome contributions to the project! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
