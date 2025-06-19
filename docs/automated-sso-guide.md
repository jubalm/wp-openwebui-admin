# Automated SSO Configuration Guide

This guide explains the **fully automated** Single Sign-On (SSO) setup for WordPress and OpenWebUI using Authentik. No manual configuration is required!

## 🚀 Quick Start

The SSO integration is now **completely automated**. Simply run:

```bash
./scripts/setup.sh
```

The setup script will:
- Deploy all services with Docker Compose
- Automatically configure Authentik OAuth applications
- Pre-configure WordPress OpenID Connect plugin
- Set up OpenWebUI OAuth integration
- Provide a ready-to-use SSO environment

## 🔧 What Gets Configured Automatically

### Authentik OAuth Applications

The system automatically creates two OAuth2/OpenID Connect applications in Authentik:

1. **WordPress Application**
   - Name: `WordPress`
   - Slug: `wordpress`
   - Client ID: `wordpress`
   - Client Secret: `wordpress-secret-auto`
   - Redirect URI: `http://localhost:8080/wp-admin/admin-ajax.php?action=openid-connect-authorize`

2. **OpenWebUI Application**
   - Name: `OpenWebUI`
   - Slug: `openwebui`
   - Client ID: `openwebui`
   - Client Secret: `openwebui-secret-auto`
   - Redirect URI: `http://localhost:3000/oauth/callback`

### WordPress OpenID Connect Plugin

The WordPress OpenID Connect Generic plugin is automatically configured with:
- Login type: Button on login form
- Client credentials from Authentik
- All endpoint URLs pre-configured
- User creation and linking enabled
- Proper username and email mapping

### OpenWebUI OAuth Integration

OpenWebUI is pre-configured with:
- OAuth client credentials
- Authentik endpoints
- Proper scopes and redirect URIs
- User role mapping

## 🎯 Testing SSO Integration

### Test WordPress SSO

1. **Access WordPress**: http://localhost:8080/wp-login.php
2. **Look for "Login with OpenID Connect" button** on the login page
3. **Click the button** to redirect to Authentik
4. **Login with Authentik credentials**: `admin` / `admin`
5. **Verify redirect** back to WordPress with successful login

### Test OpenWebUI SSO

1. **Access OpenWebUI**: http://localhost:3000
2. **Look for OAuth/SSO login option**
3. **Click OAuth login** to redirect to Authentik
4. **Login with Authentik credentials**: `admin` / `admin`
5. **Verify redirect** back to OpenWebUI with successful login

## 🔐 Service Credentials

### Automatically Created Accounts

- **WordPress Admin**: `admin` / `admin123`
- **Authentik Admin**: `admin` / `admin` (change after first login)
- **MCP API Key**: `demo-api-key-poc`

### OAuth Application Credentials

All OAuth credentials are automatically generated and configured:
- WordPress Client ID: `wordpress`
- WordPress Client Secret: `wordpress-secret-auto`
- OpenWebUI Client ID: `openwebui`
- OpenWebUI Client Secret: `openwebui-secret-auto`

## 🔄 Service URLs

- **WordPress**: http://localhost:8080
- **OpenWebUI**: http://localhost:3000
- **Authentik**: http://localhost:9000
- **MariaDB**: localhost:3306
- **PostgreSQL**: localhost:5432

## 🏗️ Architecture Overview

```
┌─────────────────┐    OAuth2/OIDC     ┌─────────────────┐
│   WordPress     │◄───────────────────┤   Authentik     │
│   + OIDC Plugin │    Auto-Config     │   (Identity     │
│   (Port 8080)   │                    │   Provider)     │
└─────────────────┘                    │   (Port 9000)   │
                                       │                 │
┌─────────────────┐    OAuth2/OIDC     │                 │
│   OpenWebUI     │◄───────────────────┤                 │
│   + OAuth       │    Auto-Config     │                 │
│   (Port 3000)   │                    │                 │
└─────────────────┘                    └─────────────────┘
```

## 🛠️ Customization

### Environment Variables

You can customize the OAuth configuration by creating a `.env` file from `.env.example`:

```bash
cp .env.example .env
```

Key variables for SSO customization:

```bash
# Enable/disable automated SSO configuration
ENABLE_AUTHENTIK_SSO=true

# Authentik service configuration
AUTHENTIK_URL=http://localhost:9000
AUTHENTIK_BOOTSTRAP_PASSWORD=admin
AUTHENTIK_BOOTSTRAP_TOKEN=bootstrap-token

# OAuth client credentials (auto-generated if not specified)
WORDPRESS_OAUTH_CLIENT_ID=wordpress
WORDPRESS_OAUTH_CLIENT_SECRET=wordpress-secret-auto
OPENWEBUI_OAUTH_CLIENT_ID=openwebui
OPENWEBUI_OAUTH_CLIENT_SECRET=openwebui-secret-auto
```

### Manual Override

If you need to disable automated SSO configuration, set:

```bash
ENABLE_AUTHENTIK_SSO=false
```

This will skip the automatic OAuth configuration and plugin setup.

## 🚨 Troubleshooting

### Common Issues

1. **"Login with OpenID Connect" button not visible**
   - Check if the OpenID Connect Generic plugin is activated
   - Verify WordPress logs: `docker logs wp-instance`

2. **OAuth redirect errors**
   - Verify service URLs are accessible
   - Check Authentik logs: `docker logs authentik-server`

3. **Configuration not applied**
   - Check the configuration service: `docker logs authentik-config`
   - Verify OAuth config file exists: `docker exec wp-instance ls -la /tmp/oauth_config.json`

### Reset Configuration

To reset the entire SSO configuration:

```bash
# Stop and remove all containers
docker-compose down -v

# Remove OAuth configuration
docker volume rm wp-openwebui-admin_oauth_config

# Start fresh
./scripts/setup.sh
```

### Debug Mode

To see detailed configuration logs:

```bash
# Check Authentik configuration
docker logs authentik-config

# Check WordPress setup
docker logs wp-instance

# Check Authentik server
docker logs authentik-server
```

## 🎉 Benefits of Automated SSO

- **Zero Manual Configuration**: No clicking through admin interfaces
- **Consistent Deployments**: Same configuration every time
- **CI/CD Ready**: Perfect for automated deployments
- **Error-Free Setup**: Eliminates manual configuration mistakes
- **Scalable**: Easy to deploy multiple instances
- **Production Ready**: Secure defaults with customization options

## 📝 Next Steps

After successful SSO setup:

1. **Change default passwords** for production use
2. **Create additional users** in Authentik for team access
3. **Configure user roles** and permissions
4. **Set up custom themes** and branding
5. **Enable additional OAuth providers** if needed

The automated SSO integration provides a solid foundation for enterprise-grade authentication across your WordPress and OpenWebUI deployment!