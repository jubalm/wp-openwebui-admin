# SSO Configuration Guide

This guide walks you through configuring Single Sign-On (SSO) for both WordPress and OpenWebUI using Authentik as the identity provider.

## Overview

The SSO setup provides:
- Centralized authentication via Authentik
- Single sign-on for WordPress and OpenWebUI
- Unified user management
- Secure OAuth2/OpenID Connect integration

## Prerequisites

1. Complete the basic setup: `./scripts/setup.sh`
2. All services should be running and accessible
3. WordPress should be configured with basic settings

## Step 1: Authentik Initial Setup

1. **Access Authentik Admin Interface**
   - URL: http://localhost:9000
   - Default credentials: `admin` / `admin`
   - **Important**: Change the admin password immediately after first login

2. **Initial Configuration**
   - Navigate to System > Settings
   - Update the domain to `localhost:9000` if not already set
   - Verify the default flow configurations are in place

## Step 2: Configure WordPress OAuth Provider

1. **Create WordPress Application in Authentik**
   - Go to Applications > Applications
   - Click "Create"
   - Name: `WordPress`
   - Slug: `wordpress`
   - Provider: Create new OAuth2/OpenID Provider

2. **Configure OAuth2/OpenID Provider for WordPress**
   - **Name**: `WordPress OAuth`
   - **Client type**: `Confidential`
   - **Client ID**: `wordpress` (note this value)
   - **Client Secret**: Generate and note this value
   - **Redirect URIs**: `http://localhost:8080/wp-admin/admin-ajax.php?action=openid-connect-authorize`
   - **Signing Key**: Select the default signing certificate
   - **Scopes**: `openid`, `profile`, `email`

3. **Application Configuration**
   - **Launch URL**: `http://localhost:8080`
   - **Icon**: Optional
   - **Publisher**: Your organization name

## Step 3: Configure OpenWebUI OAuth Provider

1. **Create OpenWebUI Application in Authentik**
   - Go to Applications > Applications
   - Click "Create"
   - Name: `OpenWebUI`
   - Slug: `openwebui`
   - Provider: Create new OAuth2/OpenID Provider

2. **Configure OAuth2/OpenID Provider for OpenWebUI**
   - **Name**: `OpenWebUI OAuth`
   - **Client type**: `Confidential`
   - **Client ID**: `openwebui` (should match OPENWEBUI_OAUTH_CLIENT_ID)
   - **Client Secret**: Generate and note this value
   - **Redirect URIs**: `http://localhost:3000/oauth/callback`
   - **Signing Key**: Select the default signing certificate
   - **Scopes**: `openid`, `profile`, `email`

3. **Application Configuration**
   - **Launch URL**: `http://localhost:3000`
   - **Icon**: Optional
   - **Publisher**: Your organization name

## Step 4: Install and Configure WordPress OpenID Connect Plugin

1. **Install Plugin**
   - Method 1: Install via WordPress admin (Plugins > Add New > Search "OpenID Connect Generic")
   - Method 2: Download from https://wordpress.org/plugins/openid-connect-generic/ and extract to `wordpress/plugins/`

2. **Activate Plugin**
   - Go to WordPress admin: http://localhost:8080/wp-admin
   - Navigate to Plugins
   - Activate "OpenID Connect Generic Client"

3. **Configure Plugin Settings**
   - Go to Settings > OpenID Connect Client
   - **Login Type**: `OpenID Connect button on login form`
   - **Client ID**: `wordpress` (from Authentik configuration)
   - **Client Secret Key**: The secret from Authentik WordPress provider
   - **OpenID Scope**: `openid profile email`
   - **Login Endpoint URL**: `http://localhost:9000/application/o/authorize/`
   - **Userinfo Endpoint URL**: `http://localhost:9000/application/o/userinfo/`
   - **Token Validation Endpoint URL**: `http://localhost:9000/application/o/token/`
   - **End Session Endpoint URL**: `http://localhost:9000/if/session-end/`

4. **Advanced Settings**
   - **Nickname Key**: `preferred_username`
   - **Email Formatting**: `{email}`
   - **Display Name Formatting**: `{given_name} {family_name}`
   - **Link Existing Users**: Enable if you want to link existing WordPress users
   - **Create user if does not exist**: Enable to auto-create users
   - **Redirect Back to Origin Page**: Enable for better UX

## Step 5: Update Environment Variables

Update your `.env` file with the generated client secrets:

```bash
# Update these with the actual values from Authentik
OPENWEBUI_OAUTH_CLIENT_SECRET=your-openwebui-client-secret-here

# WordPress OAuth is configured via the plugin interface
```

Restart the services after updating environment variables:
```bash
docker-compose down
docker-compose up -d
```

## Step 6: Test SSO Integration

### Test WordPress SSO

1. **Logout from WordPress** (if logged in)
2. **Go to WordPress login page**: http://localhost:8080/wp-login.php
3. **Click "Login with OpenID Connect"** button
4. **Redirect to Authentik**: You should be redirected to Authentik login
5. **Login with Authentik credentials**
6. **Redirect back to WordPress**: You should be logged into WordPress

### Test OpenWebUI SSO

1. **Access OpenWebUI**: http://localhost:3000
2. **Click SSO login option**: Look for OAuth/SSO login button
3. **Redirect to Authentik**: You should be redirected to Authentik login
4. **Login with Authentik credentials**
5. **Redirect back to OpenWebUI**: You should be logged into OpenWebUI

## Step 7: User Management

### Create Users in Authentik

1. **Access Authentik Admin**: http://localhost:9000
2. **Go to Directory > Users**
3. **Create user**: Click "Create" and fill in user details
4. **Set password**: Assign a secure password
5. **Assign to groups**: Optional, for role-based access

### Configure User Roles

1. **WordPress Roles**: Configured in WordPress admin or via OpenID Connect plugin settings
2. **OpenWebUI Roles**: Configured via environment variables and OpenWebUI admin
3. **Authentik Groups**: Can be mapped to application-specific roles

## Troubleshooting

### Common Issues

1. **Redirect URI Mismatch**
   - Ensure redirect URIs in Authentik match exactly with application configurations
   - Check for trailing slashes and protocol (http vs https)

2. **Client Secret Mismatch**
   - Verify client secrets are correctly copied from Authentik to application configurations
   - Check for extra spaces or characters

3. **Scope Issues**
   - Ensure `openid` scope is always included
   - Common scopes: `openid profile email`

4. **Network Connectivity**
   - Verify all services are running: `docker-compose ps`
   - Check service health: `docker-compose logs servicename`

5. **WordPress Plugin Issues**
   - Ensure plugin is activated
   - Check WordPress error logs
   - Verify plugin settings match Authentik configuration

### Debug Steps

1. **Check Authentik Logs**
   ```bash
   docker-compose logs authentik-server
   docker-compose logs authentik-worker
   ```

2. **Check WordPress Logs**
   ```bash
   docker-compose logs wordpress
   ```

3. **Check OpenWebUI Logs**
   ```bash
   docker-compose logs openwebui
   ```

4. **Test OAuth Endpoints**
   ```bash
   # Test Authentik well-known configuration
   curl http://localhost:9000/application/o/wordpress/.well-known/openid_configuration
   
   # Test OpenWebUI configuration
   curl http://localhost:9000/application/o/openwebui/.well-known/openid_configuration
   ```

## Security Considerations

1. **Change Default Passwords**: Always change default Authentik admin password
2. **Use Strong Secrets**: Generate strong client secrets and API keys
3. **HTTPS in Production**: Always use HTTPS in production environments
4. **Regular Updates**: Keep all components updated
5. **Access Logging**: Enable and monitor access logs
6. **Backup Configuration**: Regular backup of Authentik and WordPress configurations

## Next Steps

After successful SSO setup:

1. **Configure MCP Integration**: Set up WordPress MCP plugin with JWT authentication
2. **Test Complete Workflow**: Verify end-to-end integration works
3. **Production Deployment**: Plan for production deployment with proper security
4. **User Training**: Train users on the new SSO workflow
5. **Monitoring**: Set up monitoring and alerting for the authentication services

For additional help, check the individual service documentation:
- [Authentik Documentation](https://docs.goauthentik.io/)
- [OpenID Connect Generic Plugin](https://wordpress.org/plugins/openid-connect-generic/)
- [OpenWebUI Documentation](https://docs.openwebui.com/)