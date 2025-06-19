# Authentik Container Health Fix

## Issue Description
The Authentik server container healthcheck was failing because `curl` is not installed in the `ghcr.io/goauthentik/server` image. This caused the container to remain in "unhealthy" state indefinitely, preventing proper startup and dependent service initialization.

## Root Cause
The healthcheck command was using `curl`:
```yaml
test: ["CMD", "curl", "-f", "http://localhost:9000/"]
```

However, the `ghcr.io/goauthentik/server` image does not include `curl`, causing the healthcheck to always fail with "command not found" errors.

## Solution Applied
Updated the healthcheck to use Python (which is available in the Authentik container) instead of `curl`:

```yaml
healthcheck:
  test: ["CMD", "python3", "-c", "import urllib.request,sys;exec('try: urllib.request.urlopen(\"http://localhost:9000/\")\\nexcept urllib.error.HTTPError as e: sys.exit(0 if e.code == 404 else 1)\\nexcept: sys.exit(1)')"]
  start_period: 60s
  interval: 30s
  timeout: 10s
  retries: 5
```

This approach:
- Uses `python3` which is available in the Authentik container
- Handles HTTP 404 responses gracefully (Authentik returns 404 for root path, which is expected)
- Properly exits with code 0 for successful healthcheck when server responds
- Fails appropriately for actual connection issues

## Changes Made
1. **Fixed Authentik healthcheck** in `docker-compose.yml` to use Python instead of curl
2. **Tested the fix** by validating container reaches "healthy" status
3. **Verified functionality** by confirming Authentik UI remains accessible

## Testing Results
After applying the fix:
```bash
docker compose ps authentik-server
# Shows: Up About a minute (healthy)
```

The healthcheck now passes successfully and the container achieves healthy status within the expected timeframe.

## Files Modified
- `docker-compose.yml` - Updated healthcheck to use Python instead of curl

## Expected Result
- Authentik container shows as "healthy" in Docker status
- UI remains accessible at http://localhost:9000
- No more healthcheck failures or pending timeout issues
- Dependent services can properly wait for Authentik to be healthy