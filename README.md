# IONOS Proof of Concept

A proof-of-concept deployment demonstrating modern cloud infrastructure and AI-powered content creation workflows on IONOS Cloud. This project specifically aims to **showcase the capabilities of the IONOS cloud platform** for hosting a scalable and automated multi-tenant solution.

## 🎯 Purpose

This PoC explores and aims to demonstrate:

- **IONOS Cloud Capabilities:** Highlighting IONOS Managed Kubernetes orchestration, infrastructure automation, and application hosting for a multi-tenant SaaS offering.
- **Multi-Tenancy:** Securely hosting multiple tenants (starting with a single tenant for the PoC), each with their own isolated WordPress (with MCP plugin) and OpenWebUI instances.
- **Kubernetes deployment** on IONOS Cloud, leveraging IONOS Managed Kubernetes.
- **Infrastructure as Code** with Terraform for automated provisioning of all necessary IONOS resources (Kubernetes, networking, storage).
- **CI/CD automation** with GitHub Actions for streamlining development and deployment processes.
- **Automated Application Deployment:** Using Helm charts to deploy WordPress and OpenWebUI into the IONOS Kubernetes environment.
- **AI-powered content creation** with OpenWebUI, integrated with WordPress via the MCP plugin.

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
- **Core Application Stack per Tenant:** Dedicated WordPress (with MCP plugin) and OpenWebUI instances.
- **Data Persistence:** Strategy for persistent storage for WordPress and OpenWebUI using IONOS storage solutions.

## 🚀 Getting Started

To get started with the project:

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/ionos/wp-openwebui-admin.git
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
   npm start
   ```

4. **Access the Application:**
   Open your browser and navigate to `http://localhost:3000`.

## Contributing

We welcome contributions to the project! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
