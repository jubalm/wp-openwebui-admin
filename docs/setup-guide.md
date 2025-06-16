# WordPress and OpenWebUI Integration PoC Setup Guide

This guide provides step-by-step instructions for setting up and validating the integration between WordPress (with MCP plugin) and OpenWebUI.

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

2. **Run the Setup Script**
   ```bash
   ./scripts/setup.sh
   ```

3. **Complete WordPress Installation**
   - Open http://localhost:8080 in your browser
   - Follow the WordPress installation wizard
   - Create an admin user

4. **Activate MCP Plugin**
   - Go to WordPress Admin → Plugins
   - Activate "MCP Integration Plugin"

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

### 2. MCP Plugin Configuration

1. **Activate Plugin**
   - Go to WordPress Admin → Plugins
   - Activate "MCP Integration Plugin"

2. **Verify Plugin Status**
   ```bash
   curl -H "X-API-Key: demo-api-key-poc" http://localhost:8080/wp-json/mcp/v1/status
   ```

### 3. OpenWebUI Setup

1. **Access OpenWebUI**
   - URL: http://localhost:3000
   - Create admin account

2. **Configure Integration**
   - The integration is configured to communicate with WordPress via REST API
   - API Key: `demo-api-key-poc`
   - WordPress API Base: `http://localhost:8080/wp-json/mcp/v1`

## API Endpoints

The MCP plugin provides the following REST API endpoints:

### Authentication
- **Header**: `X-API-Key: demo-api-key-poc`
- **Alternative**: WordPress user authentication

### Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/mcp/v1/status` | Get plugin status |
| GET | `/mcp/v1/posts` | Get posts |
| POST | `/mcp/v1/posts` | Create post |
| PUT | `/mcp/v1/posts/{id}` | Update post |
| DELETE | `/mcp/v1/posts/{id}` | Delete post |

### Example API Calls

1. **Get Plugin Status**
   ```bash
   curl -H "X-API-Key: demo-api-key-poc" \
        http://localhost:8080/wp-json/mcp/v1/status
   ```

2. **Create Post**
   ```bash
   curl -X POST \
        -H "Content-Type: application/json" \
        -H "X-API-Key: demo-api-key-poc" \
        -d '{"title":"Test Post","content":"Test content","status":"publish"}' \
        http://localhost:8080/wp-json/mcp/v1/posts
   ```

3. **Get Posts**
   ```bash
   curl -H "X-API-Key: demo-api-key-poc" \
        http://localhost:8080/wp-json/mcp/v1/posts
   ```

## CRUD Operations Demonstration

### Create Operation
```bash
# Create a new post
curl -X POST \
     -H "Content-Type: application/json" \
     -H "X-API-Key: demo-api-key-poc" \
     -d '{
       "title": "Sample Post",
       "content": "This is sample content",
       "excerpt": "Sample excerpt",
       "status": "publish"
     }' \
     http://localhost:8080/wp-json/mcp/v1/posts
```

### Read Operation
```bash
# Get all posts
curl -H "X-API-Key: demo-api-key-poc" \
     http://localhost:8080/wp-json/mcp/v1/posts

# Get posts with pagination
curl -H "X-API-Key: demo-api-key-poc" \
     "http://localhost:8080/wp-json/mcp/v1/posts?per_page=5&offset=0"
```

### Update Operation
```bash
# Update post with ID 1
curl -X PUT \
     -H "Content-Type: application/json" \
     -H "X-API-Key: demo-api-key-poc" \
     -d '{
       "title": "Updated Post Title",
       "content": "Updated content",
       "status": "publish"
     }' \
     http://localhost:8080/wp-json/mcp/v1/posts/1
```

### Delete Operation
```bash
# Delete post with ID 1
curl -X DELETE \
     -H "X-API-Key: demo-api-key-poc" \
     http://localhost:8080/wp-json/mcp/v1/posts/1
```

## Service Configuration

### WordPress Configuration
- **URL**: http://localhost:8080
- **Database**: MariaDB 10.6
- **MCP Plugin**: Automatically loaded from `wordpress/plugins/`

### OpenWebUI Configuration
- **URL**: http://localhost:3000
- **Data Directory**: `openwebui_data` volume
- **Configuration**: `openwebui/config/` directory

### MariaDB Database
- **Host**: localhost:3306
- **Database**: wordpress
- **Username**: wordpress
- **Password**: wordpress_password
- **Root Password**: root_password

## Troubleshooting

### WordPress Issues

1. **WordPress Not Accessible**
   ```bash
   # Check if containers are running
   docker-compose ps
   
   # Check WordPress logs
   docker-compose logs wordpress
   ```

2. **Plugin Not Working**
   ```bash
   # Verify plugin file exists
   ls -la wordpress/plugins/mcp-integration.php
   
   # Check WordPress error logs
   docker-compose logs wordpress | grep -i error
   ```

3. **Database Connection Issues**
   ```bash
   # Check MariaDB logs
   docker-compose logs mysql
   
   # Test database connection
   docker-compose exec mysql mariadb -u wordpress -p wordpress
   ```

### API Issues

1. **API Not Responding**
   ```bash
   # Test WordPress REST API
   curl http://localhost:8080/wp-json/wp/v2/posts
   
   # Test MCP plugin endpoint
   curl http://localhost:8080/wp-json/mcp/v1/status
   ```

2. **Authentication Errors**
   - Verify API key: `demo-api-key-poc`
   - Check WordPress user permissions
   - Ensure plugin is activated

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
- Use strong, unique API keys
- Implement proper OAuth authentication
- Use HTTPS for all communications
- Set up proper database credentials
- Implement rate limiting
- Add input validation and sanitization
- Use environment variables for sensitive data

## Next Steps

1. **Integration Testing**: Run comprehensive tests using the test script
2. **OpenWebUI Configuration**: Configure OpenWebUI to use WordPress API
3. **Custom Workflows**: Implement custom AI-powered content creation workflows
4. **Monitoring**: Add logging and monitoring for production use
5. **Scaling**: Consider Kubernetes deployment for multi-tenant scenarios

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review Docker logs for error messages
3. Test individual components separately
4. Refer to the project documentation in `docs/`

## License

This project is licensed under the MIT License.