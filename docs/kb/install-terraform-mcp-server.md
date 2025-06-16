# Installing HashiCorp Terraform MCP Server

## Prerequisites

Before installing the Terraform MCP server, ensure you have the following:

- **Docker Installed:** The Terraform MCP server runs as a Docker container. Install Docker from [Docker's official website](https://www.docker.com/).
- **Access to HashiCorp's Terraform MCP Server Image:** Ensure you can pull the `hashicorp/terraform-mcp-server` image from Docker Hub.

## Installation Steps

1. **Pull the Docker Image:**

   ```bash
   docker pull hashicorp/terraform-mcp-server
   ```

2. **Run the MCP Server:**
   Use the following command to start the Terraform MCP server:

   ```bash
   docker run -i --rm hashicorp/terraform-mcp-server
   ```

   - `-i`: Runs the container in interactive mode.
   - `--rm`: Automatically removes the container once it stops.

3. **Verify the Server:**
   Ensure the server is running correctly by checking the logs or accessing the server endpoint.

## Notes

- The `mcp.json` configuration file in the `.vscode` directory can be used to define the server settings for development purposes.
- For production environments, consider using orchestration tools like Kubernetes to manage the MCP server instances.

## Troubleshooting

- **Docker Not Found:** Ensure Docker is installed and added to your system's PATH.
- **Image Pull Issues:** Verify your internet connection and Docker Hub access.
- **Server Errors:** Check the container logs for detailed error messages using:
  ```bash
  docker logs <container_id>
  ```
