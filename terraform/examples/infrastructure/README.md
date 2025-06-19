# Infrastructure Deployment Example

This example demonstrates how to deploy the shared infrastructure components for the multi-tenant WordPress + OpenWebUI platform on IONOS Cloud.

## What's Created

- **IONOS MariaDB Cluster**: Managed database cluster for all tenant databases
- Network security configuration
- Maintenance windows and backup settings

## Prerequisites

- IONOS Cloud account with API access
- Valid IONOS Cloud API token
- IONOS datacenter and LAN configured

## Usage

1. **Copy the example configuration:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars** with your actual values:
   - `ionos_token`: Your IONOS Cloud API token
   - `datacenter_id`: Your IONOS datacenter ID
   - `lan_id`: LAN ID for the MariaDB cluster
   - `mariadb_admin_user/password`: Admin credentials for the database

3. **Deploy the infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Note the outputs** for use in tenant configurations:
   ```bash
   terraform output mariadb_cluster_host
   terraform output mariadb_admin_username
   terraform output mariadb_admin_password
   ```

## Next Steps

After deploying the infrastructure:

1. Use the MariaDB cluster outputs to configure tenant deployments
2. Deploy individual tenants using the `single-tenant` example
3. Configure Authentik SSO integration

## Cost Considerations

This creates a managed MariaDB cluster which will incur IONOS charges based on:
- Instance size (cores/RAM)
- Storage size
- Data transfer

Review IONOS pricing for MariaDB managed services before deployment.