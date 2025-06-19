# Authentik DNS Resolution Issue

## Problem Description

The Authentik SSO service fails to start in the current environment due to DNS resolution limitations. The container cannot resolve the hostnames `postgres` and `authentik-redis` even though all containers are running in the same Docker network.

## Error Messages

```
{"event": "PostgreSQL connection failed, retrying... ([Errno -3] Temporary failure in name resolution)", "level": "info", "logger": "authentik.lib.config", "timestamp": 1750296XXX}
```

## Root Cause

This appears to be an environment-specific issue in sandboxed Docker environments where:
1. DNS resolution is restricted to external domains only
2. Inter-container hostname resolution fails despite being in the same network
3. The environment blocks internal DNS queries

## Tests Performed

- ✅ Containers are all in the same Docker network (`wp-openwebui-admin_wp-network`)
- ✅ PostgreSQL and Redis containers are healthy and accessible by IP
- ❌ DNS resolution fails: `nslookup postgres` returns `REFUSED`
- ❌ Both service names (`postgres`, `redis`) and container names (`authentik-postgres`, `authentik-redis`) fail to resolve

## Current Solution

Authentik SSO has been **temporarily disabled** to allow the core functionality to work:

1. **WordPress**: Runs with standard authentication (no SSO)
2. **OpenWebUI**: Runs with signup enabled (no SSO)
3. **MariaDB**: Works normally for WordPress

## Configuration Changes Made

- Set `ENABLE_AUTHENTIK_SSO=false` in environment variables
- Removed Authentik dependencies from WordPress and OpenWebUI services
- Enabled signup for OpenWebUI as alternative to SSO
- Updated documentation to reflect current state

## Impact

- ✅ Core WordPress functionality: **Working**
- ✅ OpenWebUI functionality: **Working**  
- ✅ WordPress MCP plugin: **Ready to install**
- ❌ Single Sign-On: **Not available**
- ❌ Unified authentication: **Not available**

## Future Resolution

When deploying in production environments:
1. Ensure proper DNS resolution between containers
2. Re-enable Authentik by setting `ENABLE_AUTHENTIK_SSO=true`
3. The configuration is ready to work once DNS issues are resolved
4. All Authentik services remain in the Docker Compose file for future use

## Testing

The current configuration has been tested and confirmed working with:
- WordPress: `http://localhost:8080`
- OpenWebUI: `http://localhost:3000`
- MariaDB: Available on port 3306