#!/bin/bash
set -euo pipefail

echo "Waiting for Authentik to be ready..."

# Use Python to check if Authentik is accessible instead of curl
python3 -c "
import requests
import time

print('Waiting for Authentik to be accessible...')
while True:
    try:
        response = requests.get('http://authentik-server:9000/if/admin/', timeout=10)
        if response.status_code == 200:
            print('Authentik is ready!')
            break
    except:
        print('Authentik not ready, waiting 5 seconds...')
        time.sleep(5)
"

echo "Authentik is ready! Starting configuration..."

# Run the Python configuration script
python configure_authentik.py

echo "Authentik configuration completed successfully!"