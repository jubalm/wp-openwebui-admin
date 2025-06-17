# IONOS Proof of Concept

A proof-of-concept deployment demonstrating modern cloud infrastructure and AI-powered content creation workflows on IONOS Cloud. This project specifically aims to **showcase the capabilities of the IONOS cloud platform** for hosting a scalable and automated multi-tenant solution.

## 🎯 Purpose

This PoC explores and aims to demonstrate:

- **IONOS Cloud Capabilities:** Highlighting IONOS Managed Kubernetes orchestration, infrastructure automation, and application hosting for a multi-tenant SaaS offering.
- **Multi-Tenancy:** Securely hosting multiple tenants (starting with a single tenant for the PoC), each with their own isolated WordPress (with official MCP plugin) and OpenWebUI instances.
- **Kubernetes deployment** on IONOS Cloud, leveraging IONOS Managed Kubernetes.
- **Infrastructure as Code** with Terraform for automated provisioning of all necessary IONOS resources (Kubernetes, networking, storage).
- **CI/CD automation** with GitHub Actions for streamlining development and deployment processes.
- **Automated Application Deployment:** Using Helm charts to deploy WordPress and OpenWebUI into the IONOS Kubernetes environment.
- **AI-powered content creation** with OpenWebUI, integrated with WordPress via the official MCP plugin.

## 🏗️ Project Structure

The project is organized as follows:

```
.
├── .github/              # GitHub Actions workflows for CI/CD
├── docs/                 # Project documentation
│   ├── kb/               # Knowledgebase, learnings, external resources, tooling
├── iac/                  # Infrastructure as Code
│   └── terraform/        # Terraform modules and configurations for IONOS
│       ├── modules/      # Reusable Terraform modules (e.g., for tenant infra)
│       └── environments/ # Environment-specific configurations (e.g., poc)
├── helm/                 # Helm charts for applications
│   ├── wordpress-mcp/    # Helm chart for WordPress + MCP Plugin
│   └── openwebui/        # Helm chart for OpenWebUI
├── scripts/              # Helper scripts for automation, deployment, etc.
└── README.md             # This file
```

## ✨ Key Features (PoC Scope)

- **IONOS Secure Cloud Management:** Demonstrates IONOS Managed Kubernetes, networking (LoadBalancer for IP exposure), and storage solutions with a focus on security and scalability.
- **Multi-Tenant Architecture:** Implements a strategy for securely hosting multiple tenants within the same infrastructure. Each tenant is isolated using Kubernetes namespaces, ensuring data security and resource efficiency. This architecture supports scalability and allows for efficient utilization of cloud resources.
- **Automated Infrastructure Provisioning:** Using Terraform to create reusable modules for tenant infrastructure on IONOS.
- **Automated Application Deployment:** Customizable Helm charts for deploying WordPress (with MCP) and OpenWebUI.
- **Core Application Stack per Tenant:** Dedicated WordPress (with official MCP plugin) and OpenWebUI instances.
- **Data Persistence:** Strategy for persistent storage for WordPress and OpenWebUI using IONOS storage solutions.
- **🎯 PoC Implementation Complete**: Full working integration with CRUD operations validated

### Demonstrated Capabilities

- ✅ **WordPress Deployment**: Local WordPress instance with MariaDB database
- ✅ **Official WordPress MCP Plugin**: Automattic's official MCP plugin with standardized protocol
- ✅ **MCP Protocol Implementation**: Dual transport protocols (STDIO & Streamable) with JWT authentication
- ✅ **OpenWebUI Integration**: Ready for AI-powered content management
- ✅ **CRUD Operations**: Full WordPress content management via MCP tools
- ✅ **Docker Orchestration**: Complete containerized environment
- ✅ **Kubernetes Ready**: Helm charts for production deployment
- ✅ **MariaDB Compatibility**: Optimized for IONOS Cloud deployment
- ✅ **OpenWebUI Deployment**: Ready for AI-powered content workflows
- ✅ **CRUD Operations**: Create, Read, Update, Delete operations via API
- ✅ **Documentation**: Complete setup and integration guides
- ✅ **Automation**: Scripts for setup, testing, and cleanup

## 🚀 Getting Started

### Quick Start (PoC Demo)

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/jubalm/wp-openwebui-admin.git
   cd wp-openwebui-admin
   ```

2. **Run the Setup Script:**
   ```bash
   ./scripts/setup.sh
   ```

3. **Complete WordPress Setup:**
   - Open http://localhost:8080 in your browser
   - Follow WordPress installation wizard
   - Activate the MCP Integration plugin

4. **Test the Integration:**
   ```bash
   ./scripts/test-integration.sh
   ```

5. **Access Services:**
   - **WordPress**: http://localhost:8080
   - **OpenWebUI**: http://localhost:3000

### Prerequisites

- **Docker & Docker Compose**: [Installation Guide](https://docs.docker.com/get-docker/)
- **Git**: For cloning the repository
- **curl**: For testing API endpoints

## 📚 Documentation

- **[Setup Guide](docs/setup-guide.md)**: Comprehensive installation and configuration guide
- **[PoC Report](docs/poc-report.md)**: Complete proof of concept implementation report
- **[Scripts Documentation](scripts/README.md)**: Helper scripts usage guide

## 🧪 PoC Status: COMPLETE ✅

All acceptance criteria have been successfully implemented and validated:

1. ✅ **WordPress Local Deployment**: Running on http://localhost:8080
2. ✅ **MCP Plugin**: Custom integration plugin with REST API
3. ✅ **OpenWebUI Deployment**: Running on http://localhost:3000
4. ✅ **Integration Configuration**: WordPress-OpenWebUI communication established
5. ✅ **CRUD Operations**: All operations validated with automated tests
6. ✅ **Documentation**: Complete setup, usage, and troubleshooting guides

### Quick Validation
```bash
# Run the complete PoC setup and test
./scripts/setup.sh
./scripts/test-integration.sh
```

## 🔧 API Integration

The MCP plugin provides REST API endpoints for WordPress-OpenWebUI integration:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/mcp/v1/status` | GET | Plugin status |
| `/mcp/v1/posts` | GET | Retrieve posts |
| `/mcp/v1/posts` | POST | Create post |
| `/mcp/v1/posts/{id}` | PUT | Update post |
| `/mcp/v1/posts/{id}` | DELETE | Delete post |

**Authentication**: API Key (`X-API-Key: demo-api-key-poc`)

## Contributing

We welcome contributions to the project! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
