#!/bin/bash
set -euo pipefail

echo "Starting simplified WordPress setup..."

# Just run the original WordPress entrypoint with all the functionality
# Let WordPress handle the setup properly without interference
exec /usr/local/bin/docker-entrypoint.sh "$@"