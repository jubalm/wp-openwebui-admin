#!/bin/bash
set -e

echo "Testing WordPress automation..."

# Clean up any existing containers
echo "Cleaning up existing containers..."
docker stop wp-test-mysql wp-test-wordpress 2>/dev/null || true
docker rm wp-test-mysql wp-test-wordpress 2>/dev/null || true

# Start MySQL
echo "Starting MySQL container..."
docker run -d --name wp-test-mysql \
  -e MARIADB_DATABASE=wordpress \
  -e MARIADB_USER=wordpress \
  -e MARIADB_PASSWORD=wordpress_password \
  -e MARIADB_ROOT_PASSWORD=root_password \
  mariadb:10.6

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
sleep 15

# Build WordPress image
echo "Building WordPress image..."
docker build -t wp-test-auto ./docker/wordpress/

# Get MySQL IP
MYSQL_IP=$(docker inspect wp-test-mysql | grep '"IPAddress"' | head -1 | sed 's/.*"IPAddress": "\(.*\)".*/\1/')
echo "MySQL IP: $MYSQL_IP"

# Start WordPress
echo "Starting WordPress container..."
docker run -d --name wp-test-wordpress -p 8080:80 \
  -e WORDPRESS_DB_HOST=$MYSQL_IP:3306 \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=wordpress_password \
  -e WORDPRESS_DB_NAME=wordpress \
  -e WORDPRESS_URL=http://localhost:8080 \
  -e WORDPRESS_TITLE="Automated WordPress Test" \
  -e WORDPRESS_DESCRIPTION="Testing automated WordPress setup" \
  -e WORDPRESS_ADMIN_USER=admin \
  -e WORDPRESS_ADMIN_PASS=admin \
  -e WORDPRESS_ADMIN_EMAIL=admin@test.com \
  wp-test-auto

# Show WordPress logs
echo "WordPress container logs:"
sleep 30
docker logs wp-test-wordpress

# Test if WordPress is responding
echo "Testing WordPress response..."
sleep 10
echo "Checking if WordPress is responding..."
curl -s http://localhost:8080 > /tmp/wp_response.html
if grep -q "Automated WordPress Test" /tmp/wp_response.html; then
    echo "✅ SUCCESS: WordPress is responding with automated setup!"
    echo "✅ Site title found in response - automation worked!"
elif grep -q "wp-admin/install.php" /tmp/wp_response.html; then
    echo "❌ FAILED: WordPress setup wizard is still showing"
    echo "Response preview:"
    head -10 /tmp/wp_response.html
elif grep -q "WordPress" /tmp/wp_response.html; then
    echo "⚠️  WordPress is responding but title not found. Checking content:"
    head -20 /tmp/wp_response.html
else
    echo "❌ FAILED: WordPress not responding or unexpected content"
    echo "Response preview:"
    head -20 /tmp/wp_response.html
fi

# Cleanup
echo "Cleaning up..."
docker stop wp-test-mysql wp-test-wordpress
docker rm wp-test-mysql wp-test-wordpress

echo "Test completed."