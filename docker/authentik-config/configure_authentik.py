#!/usr/bin/env python3
"""
Authentik OAuth Application Auto-Configuration Script

This script automatically configures Authentik with OAuth2/OpenID Connect applications
for WordPress and OpenWebUI integration, eliminating manual setup requirements.
"""
import requests
import json
import os
import sys
import time
from typing import Dict, Optional

class AuthentikConfigurator:
    def __init__(self):
        self.base_url = os.getenv('AUTHENTIK_URL', 'http://authentik-server:9000')
        self.username = os.getenv('AUTHENTIK_USERNAME', 'akadmin')  # Default admin user
        self.password = os.getenv('AUTHENTIK_BOOTSTRAP_PASSWORD', 'admin')
        self.token = None
        self.session = requests.Session()
        
        # Application configurations
        self.wordpress_config = {
            'name': 'WordPress',
            'slug': 'wordpress',
            'client_id': os.getenv('WORDPRESS_OAUTH_CLIENT_ID', 'wordpress'),
            'client_secret': os.getenv('WORDPRESS_OAUTH_CLIENT_SECRET', 'wordpress-secret-auto'),
            'redirect_uris': [
                f"{os.getenv('SITE_URL', 'http://localhost:8080')}/wp-admin/admin-ajax.php?action=openid-connect-authorize"
            ],
            'launch_url': os.getenv('SITE_URL', 'http://localhost:8080')
        }
        
        self.openwebui_config = {
            'name': 'OpenWebUI',
            'slug': 'openwebui',
            'client_id': os.getenv('OPENWEBUI_OAUTH_CLIENT_ID', 'openwebui'),
            'client_secret': os.getenv('OPENWEBUI_OAUTH_CLIENT_SECRET', 'openwebui-secret-auto'),
            'redirect_uris': [
                f"{os.getenv('WEBUI_URL', 'http://localhost:3000')}/oauth/callback"
            ],
            'launch_url': os.getenv('WEBUI_URL', 'http://localhost:3000')
        }

    def authenticate(self) -> bool:
        """Authenticate with Authentik and get access token"""
        try:
            # Get CSRF token first
            csrf_response = self.session.get(f"{self.base_url}/if/admin/")
            if csrf_response.status_code != 200:
                print(f"Failed to get CSRF token: {csrf_response.status_code}")
                return False
            
            # Parse CSRF token from response
            csrf_token = None
            if 'csrftoken=' in csrf_response.headers.get('Set-Cookie', ''):
                csrf_token = csrf_response.cookies.get('authentik_csrftoken')
            
            # Try token authentication first
            token = os.getenv('AUTHENTIK_BOOTSTRAP_TOKEN')
            if token:
                self.session.headers.update({'Authorization': f'Bearer {token}'})
                test_response = self.session.get(f"{self.base_url}/api/v3/core/applications/")
                if test_response.status_code == 200:
                    print("Successfully authenticated with bootstrap token")
                    return True
                else:
                    print("Bootstrap token authentication failed, trying login...")
            
            # Login with username/password
            login_data = {
                'username': self.username,
                'password': self.password
            }
            
            if csrf_token:
                login_data['csrfmiddlewaretoken'] = csrf_token
                self.session.headers.update({'X-CSRFToken': csrf_token, 'Referer': f"{self.base_url}/if/admin/"})
            
            login_response = self.session.post(f"{self.base_url}/if/flow/default-authentication-flow/", data=login_data)
            
            if login_response.status_code == 200:
                print("Successfully authenticated with Authentik")
                return True
            else:
                print(f"Authentication failed: {login_response.status_code}")
                return False
                
        except Exception as e:
            print(f"Authentication error: {e}")
            return False

    def get_default_certificate(self) -> Optional[str]:
        """Get the default signing certificate UUID"""
        try:
            response = self.session.get(f"{self.base_url}/api/v3/crypto/certificatekeypairs/")
            if response.status_code == 200:
                certs = response.json()['results']
                if certs:
                    return certs[0]['pk']  # Return first available certificate
            return None
        except Exception as e:
            print(f"Error getting certificate: {e}")
            return None

    def create_oauth_provider(self, app_config: Dict) -> Optional[str]:
        """Create OAuth2/OpenID Connect provider"""
        try:
            cert_id = self.get_default_certificate()
            
            provider_data = {
                'name': f"{app_config['name']} OAuth Provider",
                'client_type': 'confidential',
                'client_id': app_config['client_id'],
                'client_secret': app_config['client_secret'],
                'redirect_uris': '\n'.join(app_config['redirect_uris']),
                'signing_key': cert_id,
                'sub_mode': 'hashed_user_id',
                'include_claims_in_id_token': True,
                'issuer_mode': 'per_provider'
            }
            
            response = self.session.post(f"{self.base_url}/api/v3/providers/oauth2/", json=provider_data)
            
            if response.status_code == 201:
                provider_id = response.json()['pk']
                print(f"Created OAuth provider for {app_config['name']}: {provider_id}")
                return provider_id
            else:
                print(f"Failed to create OAuth provider for {app_config['name']}: {response.status_code}")
                print(f"Response: {response.text}")
                return None
                
        except Exception as e:
            print(f"Error creating OAuth provider for {app_config['name']}: {e}")
            return None

    def create_application(self, app_config: Dict, provider_id: str) -> bool:
        """Create application in Authentik"""
        try:
            app_data = {
                'name': app_config['name'],
                'slug': app_config['slug'],
                'provider': provider_id,
                'launch_url': app_config['launch_url'],
                'open_in_new_tab': True
            }
            
            response = self.session.post(f"{self.base_url}/api/v3/core/applications/", json=app_data)
            
            if response.status_code == 201:
                print(f"Created application: {app_config['name']}")
                return True
            else:
                print(f"Failed to create application {app_config['name']}: {response.status_code}")
                print(f"Response: {response.text}")
                return False
                
        except Exception as e:
            print(f"Error creating application {app_config['name']}: {e}")
            return False

    def check_existing_application(self, slug: str) -> bool:
        """Check if application already exists"""
        try:
            response = self.session.get(f"{self.base_url}/api/v3/core/applications/?slug={slug}")
            if response.status_code == 200:
                apps = response.json()['results']
                return len(apps) > 0
            return False
        except Exception as e:
            print(f"Error checking existing application {slug}: {e}")
            return False

    def configure_application(self, app_config: Dict) -> bool:
        """Configure a complete OAuth application"""
        if self.check_existing_application(app_config['slug']):
            print(f"Application {app_config['name']} already exists, skipping...")
            return True
        
        # Create OAuth provider
        provider_id = self.create_oauth_provider(app_config)
        if not provider_id:
            return False
        
        # Create application
        return self.create_application(app_config, provider_id)

    def save_config_to_file(self):
        """Save OAuth configuration to file for use by other services"""
        config_data = {
            'wordpress': {
                'client_id': self.wordpress_config['client_id'],
                'client_secret': self.wordpress_config['client_secret'],
                'issuer_url': f"{self.base_url}/application/o/{self.wordpress_config['slug']}/",
                'authorization_endpoint': f"{self.base_url}/application/o/authorize/",
                'token_endpoint': f"{self.base_url}/application/o/token/",
                'userinfo_endpoint': f"{self.base_url}/application/o/userinfo/",
                'end_session_endpoint': f"{self.base_url}/if/session-end/"
            },
            'openwebui': {
                'client_id': self.openwebui_config['client_id'],
                'client_secret': self.openwebui_config['client_secret'],
                'authorization_url': f"{self.base_url}/application/o/authorize/",
                'token_url': f"{self.base_url}/application/o/token/",
                'userinfo_url': f"{self.base_url}/application/o/userinfo/"
            }
        }
        
        with open('/tmp/oauth_config.json', 'w') as f:
            json.dump(config_data, f, indent=2)
        
        print("OAuth configuration saved to /tmp/oauth_config.json")

    def run(self):
        """Main configuration process"""
        print("Starting Authentik OAuth configuration...")
        
        # Wait a bit for Authentik to fully initialize
        time.sleep(10)
        
        # Authenticate
        if not self.authenticate():
            print("Failed to authenticate with Authentik")
            sys.exit(1)
        
        # Configure WordPress application
        if self.configure_application(self.wordpress_config):
            print("✓ WordPress OAuth application configured successfully")
        else:
            print("✗ Failed to configure WordPress OAuth application")
        
        # Configure OpenWebUI application
        if self.configure_application(self.openwebui_config):
            print("✓ OpenWebUI OAuth application configured successfully")
        else:
            print("✗ Failed to configure OpenWebUI OAuth application")
        
        # Save configuration
        self.save_config_to_file()
        
        print("Authentik configuration completed!")

if __name__ == "__main__":
    configurator = AuthentikConfigurator()
    configurator.run()