#!/bin/bash
# Customize these variables
DOMAIN="your-domain"  # e.g., wcs
REPO="your-repo"      # e.g., pypi-store
REGION="us-west-2"    # Your AWS region
NGINX_CONF="/etc/nginx/conf.d/codeartifact-proxy.conf"

# Fetch the authorization token
TOKEN=$(aws codeartifact get-authorization-token --domain $DOMAIN --domain-owner $(aws sts get-caller-identity --query Account --output text) --region $REGION --query authorizationToken --output text)

# Base64 encode "aws:<token>" for Basic Auth
BASIC_AUTH=$(echo -n "aws:$TOKEN" | base64 -w 0)

# Update the Nginx config (using # as delimiter for safety)
sed -i "s#proxy_set_header Authorization \"Basic .*#proxy_set_header Authorization \"Basic $BASIC_AUTH\";#" $NGINX_CONF

# Check if sed succeeded
if [ $? -ne 0 ]; then
    echo "Error: sed failed to update the config."
    exit 1
fi

# Reload Nginx
sudo systemctl reload nginx

echo "Token updated at $(date) - BASIC_AUTH length: ${#BASIC_AUTH}"
