# WordPress OpenID Connect Plugin Installation

Since the OpenID Connect Generic plugin cannot be automatically downloaded during setup due to network restrictions, you need to manually install it:

## Option 1: Download and Install Manually

1. Download the plugin from WordPress.org:
   https://wordpress.org/plugins/openid-connect-generic/

2. Extract the zip file to `wordpress/plugins/openid-connect-generic/`

## Option 2: Install via WordPress Admin (Recommended)

1. Access WordPress admin at http://localhost:8080/wp-admin
2. Go to Plugins > Add New
3. Search for "OpenID Connect Generic"
4. Install and activate the plugin

## Configuration

After installation, configure the plugin with these Authentik settings:

- **Identity Provider Name**: Authentik
- **Login Endpoint URL**: http://localhost:9000/application/o/authorize/
- **Userinfo Endpoint URL**: http://localhost:9000/application/o/userinfo/
- **Token Validation Endpoint URL**: http://localhost:9000/application/o/token/
- **End Session Endpoint URL**: http://localhost:9000/if/session-end/
- **Client ID**: wordpress (configure this in Authentik)
- **Client Secret**: wordpress-secret (configure this in Authentik)
- **Scope**: openid profile email
- **Login Type**: auto
- **Nickname Key**: preferred_username
- **Email Format**: {email}
- **Displayname Format**: {name}

## Authentik Configuration

You'll need to create an OAuth2/OpenID provider in Authentik:

1. Access Authentik admin at http://localhost:9000
2. Login with admin/admin (default credentials)
3. Go to Applications > Providers > Create OAuth2/OpenID Provider
4. Set up the provider with the WordPress redirect URI: http://localhost:8080/wp-admin/admin-ajax.php?action=openid-connect-authorize

This file will be updated with automated installation once network restrictions are resolved.