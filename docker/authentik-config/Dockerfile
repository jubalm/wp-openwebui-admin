FROM alpine:latest

# Install basic tools
RUN apk add --no-cache bash

# Copy configuration script
COPY docker/authentik-config/configure_authentik.sh /app/configure_authentik.sh

RUN chmod +x /app/configure_authentik.sh

WORKDIR /app

# Default command to run the configuration
CMD ["./configure_authentik.sh"]