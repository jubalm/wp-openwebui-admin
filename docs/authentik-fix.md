# Authentik Container Health Fix

## Issue Description
The Authentik UI loads correctly at http://localhost:9000 but the Docker container's healthcheck fails, causing the container to appear "unhealthy" even though it's functional. This is typically due to an overly specific healthcheck endpoint that may not be immediately available.

## Root Cause
The previous healthcheck was targeting a specific authentication flow endpoint:
```yaml
test: ["CMD", "curl", "-f", "-L", "http://localhost:9000/if/flow/default-authentication-flow/"]
```

This endpoint may require authentication or redirect, causing the healthcheck to fail.

## Solution Applied
Updated the healthcheck to use the simpler root endpoint:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:9000/"]
  start_period: 60s
  interval: 30s
  timeout: 10s
  retries: 5
```

## Changes Made
1. **Fixed Authentik healthcheck** in `docker-compose.yml` 
2. **Created dedicated Authentik test script** (`scripts/test-authentik.sh`)
3. **Updated SSO test script** with file-based logging 
4. **Enhanced debugging capabilities** with log files saved to `/tmp/authentik-logs/`

## Testing
Use the new test script to validate Authentik health:
```bash
./scripts/test-authentik.sh
```

This script:
- Checks Docker container status
- Tests UI accessibility at http://localhost:9000
- Validates admin interface and OAuth endpoints
- Tests inter-container connectivity
- Saves all logs to files for debugging (following recommendation to avoid streaming logs)

## Files Modified
- `docker-compose.yml` - Fixed healthcheck endpoint
- `scripts/test-authentik.sh` - New comprehensive Authentik test
- `scripts/test-sso.sh` - Updated with file-based logging
- `scripts/setup.sh` - Added reference to new test
- `scripts/README.md` - Documentation updates

## Expected Result
- Authentik container should show as "healthy" in Docker
- UI remains accessible at http://localhost:9000
- No more pending timeout issues during startup
- Enhanced debugging capabilities for future issues