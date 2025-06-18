# WordPress and OpenWebUI Integration PoC Setup Guide

This guide provides step-by-step instructions for setting up and validating the integration between WordPress (with the official WordPress MCP plugin) and OpenWebUI.

## Prerequisites

Before starting, ensure you have the following installed:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)
- **Git**: For cloning the repository
- **curl**: For testing API endpoints

## Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/jubalm/wp-openwebui-admin.git
   cd wp-openwebui-admin
   ```

2. **Configure Environment (Optional)**
   ```bash
   # Copy the example environment file and customize if needed
   cp .env.example .env
   # Edit .env file to customize ports, passwords, etc.
   # If no .env file is present, default values will be used
   ```

3. **Run the Setup Script**
   ```bash
   ./scripts/setup.sh
   ```
   
   **🎉 That's it! WordPress is now fully automated:**
   - ✅ WordPress core installed automatically
   - ✅ Admin user created (admin/admin123)
   - ✅ WordPress MCP plugin activated and configured
   - ✅ OpenID Connect plugin ready for SSO
   - ✅ API keys generated automatically

4. **Verify the Setup**
   - WordPress: http://localhost:8080 (admin/admin123)
   - WordPress Admin: http://localhost:8080/wp-admin
   - OpenWebUI: http://localhost:3000
   - Authentik: http://localhost:9000 (admin/admin)

5. **Test the Integration**
   ```bash
   ./scripts/test-integration.sh
   ```

## Manual Setup Steps

### 1. WordPress Setup

1. **Start Services**
   ```bash
   docker-compose up -d
   ```

2. **Access WordPress**
   - URL: http://localhost:8080
   - Complete the installation wizard
   - Note: Database connection is pre-configured

3. **Configure WordPress**
   - Create admin user
   - Set site title and description
   - Configure permalinks (Settings → Permalinks → Post name)

### 2. WordPress MCP Plugin Configuration

1. **Activate Plugin**
   - Go to WordPress Admin → Plugins
   - Activate "WordPress MCP" plugin

2. **Configure MCP Settings**
   - Go to Settings → MCP Settings
   - Enable MCP functionality
   - Configure authentication settings

3. **Generate JWT Token**
   - In MCP Settings, go to Authentication Tokens
   - Generate a new JWT token
   - Copy the token for use in API calls

4. **Alternative: Application Password**
   - Go to Users → Profile → Application Passwords
   - Generate a new application password
   - Use with basic authentication

5. **Verify Plugin Status**
   ```bash
   # Check MCP STDIO endpoint
   curl http://localhost:8080/wp-json/wp/v2/wpmcp
   
   # Check MCP Streamable endpoint  
   curl http://localhost:8080/wp-json/wp/v2/wpmcp/streamable
   ```

### 3. OpenWebUI Setup

1. **Access OpenWebUI**
   - URL: http://localhost:3000
   - Create admin account

2. **Configure MCP Integration**
   - Install Node.js (version 22 or higher) if using mcp-wordpress-remote
   - Configure MCP client to connect to WordPress MCP endpoints
   - Use JWT tokens or application passwords for authentication

## MCP Integration Architecture

The WordPress MCP plugin provides two transport protocols:

### STDIO Transport
- **Endpoint**: `/wp/v2/wpmcp`
- **Format**: WordPress-style responses
- **Authentication**: JWT tokens or Application Passwords
- **Use with**: mcp-wordpress-remote proxy

### Streamable Transport
- **Endpoint**: `/wp/v2/wpmcp/streamable`
- **Format**: JSON-RPC 2.0
- **Authentication**: JWT tokens only
- **Use with**: Direct AI client connections

## Available MCP Tools

The WordPress MCP plugin provides standardized tools for:

### Posts Management
- `wp_posts_search` - Search and filter posts
- `wp_get_post` - Get post by ID
- `wp_add_post` - Create new posts
- `wp_update_post` - Update existing posts
- `wp_delete_post` - Delete posts

### Users Management
- `wp_users_search` - Search users
- `wp_get_user` - Get user by ID
- `wp_add_user` - Create users
- `wp_update_user` - Update users
- `wp_delete_user` - Delete users

### Site Settings
- `wp_get_site_info` - Get site information
- `wp_update_site_settings` - Update site settings

## Authentication Methods

### JWT Tokens (Recommended)
```bash
# Generate token in WordPress: Settings > MCP > Authentication Tokens
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:8080/wp-json/wp/v2/posts
```

### Application Passwords
```bash
# Create in Users > Profile > Application Passwords
curl -u "username:app_password" \
     http://localhost:8080/wp-json/wp/v2/posts
```
## Example API Usage

### Direct WordPress REST API
```bash
# Create a post using WordPress REST API
curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -d '{
       "title": "AI Generated Post",
       "content": "This post was created via the WordPress MCP integration",
       "status": "publish"
     }' \
     http://localhost:8080/wp-json/wp/v2/posts
```

### Using mcp-wordpress-remote
```bash
# Install the MCP WordPress Remote package
npx @automattic/mcp-wordpress-remote@latest

# Set environment variables
export WP_API_URL="http://localhost:8080/"
export JWT_TOKEN="your-jwt-token-here"
```

## Environment Configuration

The setup uses environment variables that can be customized through a `.env` file:

### Creating Environment File

```bash
# Copy the example file
cp .env.example .env

# Edit with your preferred values
nano .env
```

### Available Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MARIADB_DATABASE` | `wordpress` | WordPress database name |
| `MARIADB_USER` | `wordpress` | MariaDB user for WordPress |
| `MARIADB_PASSWORD` | `wordpress_password` | MariaDB password for WordPress |
| `MARIADB_ROOT_PASSWORD` | `root_password` | MariaDB root password |
| `AUTHENTIK_DB_USER` | `authentik` | PostgreSQL user for Authentik |
| `AUTHENTIK_DB_NAME` | `authentik` | PostgreSQL database for Authentik |
| `AUTHENTIK_DB_PASSWORD` | `authentik_password` | PostgreSQL password for Authentik |
| `WORDPRESS_PORT` | `8080` | WordPress HTTP port |
| `OPENWEBUI_PORT` | `3000` | OpenWebUI HTTP port |
| `MYSQL_PORT` | `3306` | MariaDB port |
| `POSTGRES_PORT` | `5432` | PostgreSQL port |
| `AUTHENTIK_PORT` | `9000` | Authentik HTTP port |
| `WORDPRESS_CONFIG_EXTRA` | `define('WP_ENVIRONMENT_TYPE', 'local');` | Extra WordPress configuration |

### WordPress Site Configuration (SITE_* variables)

The WordPress Docker image supports fully automated installation using the following environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `SITE_URL` | `http://localhost:8080` | WordPress site URL |
| `SITE_TITLE` | `WordPress MCP Integration` | Site title |
| `SITE_ADMIN_USER` | `admin` | Admin username |
| `SITE_ADMIN_PASSWORD` | `admin123` | Admin password |
| `SITE_ADMIN_EMAIL` | `admin@example.com` | Admin email address |

**Note**: These variables enable zero-configuration WordPress deployment. The setup wizard is completely bypassed, and WordPress is ready to use immediately after container startup.

### Key Configuration Notes

- **`WORDPRESS_CONFIG_EXTRA`**: Set to `define('WP_ENVIRONMENT_TYPE', 'local');` to enable application passwords without SSL
- **Ports**: Ensure the specified ports are available on your system
- **Passwords**: Change default passwords for production use

## Service Configuration

### WordPress Configuration
- **URL**: http://localhost:8080
- **Database**: MariaDB 10.6 (dedicated)
- **MCP Plugin**: Official WordPress MCP plugin
- **Plugin Path**: `wordpress/plugins/wordpress-mcp/`

### OpenWebUI Configuration
- **URL**: http://localhost:3000
- **Data Directory**: `openwebui_data` volume
- **Configuration**: `openwebui/config/` directory
- **Authentication**: Authentik SSO integration

### Authentik Configuration
- **URL**: http://localhost:9000
- **Database**: PostgreSQL 15 (dedicated)
- **Default credentials**: admin/admin (change on first login)

### MariaDB Database (WordPress)
- **Host**: localhost:3306
- **Database**: wordpress
- **Username**: wordpress
- **Password**: wordpress_password
- **Root Password**: root_password

### PostgreSQL Database (Authentik)
- **Host**: localhost:5432
- **Database**: authentik
- **Username**: authentik
- **Password**: authentik_password

## Troubleshooting

### WordPress Issues

1. **WordPress Not Accessible**
   ```bash
   # Check if containers are running
   docker-compose ps
   
   # Check WordPress logs
   docker-compose logs wordpress
   ```

2. **MCP Plugin Not Working**
   ```bash
   # Verify plugin directory exists
   ls -la wordpress/plugins/wordpress-mcp/
   
   # Check if composer dependencies are installed
   ls -la wordpress/plugins/wordpress-mcp/vendor/
   ```

3. **Database Connection Issues**
   ```bash
   # Check MariaDB logs (WordPress)
   docker-compose logs mysql
   
   # Check PostgreSQL logs (Authentik)
   docker-compose logs postgres
   
   # Test MariaDB connection
   docker-compose exec mysql mariadb -u wordpress -p wordpress
   
   # Test PostgreSQL connection
   docker-compose exec postgres psql -U authentik -d authentik
   ```

### MCP Integration Issues

1. **MCP Endpoints Not Responding**
   ```bash
   # Test MCP STDIO endpoint
   curl http://localhost:8080/wp-json/wp/v2/wpmcp
   
   # Test MCP Streamable endpoint
   curl http://localhost:8080/wp-json/wp/v2/wpmcp/streamable
   ```

2. **Authentication Errors**
   - Generate JWT tokens in WordPress: Settings → MCP Settings
   - Or create Application Passwords in Users → Profile
   - Ensure MCP functionality is enabled in plugin settings

### OpenWebUI Issues

1. **OpenWebUI Not Starting**
   ```bash
   # Check OpenWebUI logs
   docker-compose logs openwebui
   
   # Restart OpenWebUI
   docker-compose restart openwebui
   ```

## Security Considerations

⚠️ **Important**: This is a Proof of Concept setup for local development only.

### Production Considerations:
- Use strong JWT tokens with appropriate expiration times
- Implement proper user authentication and authorization
- Use HTTPS for all communications
- Set up proper database credentials
- Implement rate limiting for MCP endpoints
- Add input validation and sanitization
- Use environment variables for sensitive data
- Enable WordPress security features

## Next Steps

1. **Complete WordPress Setup**: Finish WordPress installation and activate the MCP plugin
2. **Configure MCP Settings**: Enable MCP functionality and generate authentication tokens
3. **Test Integration**: Run the test script to verify MCP functionality
4. **OpenWebUI Integration**: Configure OpenWebUI to connect to WordPress MCP endpoints
5. **Custom Workflows**: Implement AI-powered content creation workflows
6. **Production Deployment**: Plan for Kubernetes deployment with proper security

## Additional Resources

- [WordPress MCP Plugin Documentation](https://github.com/Automattic/wordpress-mcp)
- [MCP WordPress Remote Client](https://github.com/Automattic/mcp-wordpress-remote)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [WordPress REST API Documentation](https://developer.wordpress.org/rest-api/)

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review Docker logs for error messages
3. Test individual components separately
4. Refer to the official WordPress MCP plugin documentation

## License

This project is licensed under the MIT License.