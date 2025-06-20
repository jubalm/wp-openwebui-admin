# Infrastructure Deployment Example

This example demonstrates how to deploy the shared infrastructure components for the multi-tenant WordPress + OpenWebUI platform on IONOS Cloud.

## What's Created

- **IONOS Datacenter**: Virtual datacenter for the platform
- **IONOS PostgreSQL Cluster**: Managed database cluster for Authentik SSO
- Network security configuration
- Maintenance windows and backup settings

## Prerequisites

- IONOS Cloud account with API access
- Valid IONOS Cloud API token

## Usage

1. **Copy the example configuration:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars** with your actual values:
   - `ionos_token`: Your IONOS Cloud API token
   - `lan_id`: LAN ID for the infrastructure
   - `postgres_admin_username/password`: Admin credentials for PostgreSQL

3. **Deploy the infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Note the outputs** for use in tenant configurations:
   ```bash
   terraform output datacenter_id
   terraform output postgres_cluster_dns_name
   terraform output postgres_admin_username
   terraform output postgres_admin_password
   ```

## Next Steps

After deploying the infrastructure:

1. Use the datacenter_id output to configure tenant deployments
2. Deploy individual tenants using the `single-tenant` example - each gets its own MariaDB cluster
3. Configure Authentik SSO integration using the PostgreSQL cluster

## Architecture Changes

This streamlined setup creates:
- **Datacenter**: Using the existing `datacenter` module
- **PostgreSQL for Authentik**: IONOS hosted PostgreSQL for SSO
- **OpenWebUI**: Uses SQLite (built-in) 
- **Single tenants**: Each gets a separate MariaDB cluster for privacy

## Cost Considerations

This creates:
- A datacenter (minimal cost)
- A managed PostgreSQL cluster for Authentik
- Each tenant will create its own MariaDB cluster (separate billing)

Review IONOS pricing for managed database services before deployment.