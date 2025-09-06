
#!/usr/bin/env bash
# update-token.sh - Refresh AWS CodeArtifact token and update Nginx config
#
# Usage: ./update-token.sh
#
# This script fetches a new CodeArtifact token and updates the Nginx config with the new token.
#
# Required environment variables or edit below:
DOMAIN="your-codeartifact-domain"      # e.g., wcs-123456789012
REPO="your-repo"                      # e.g., pypi-store
REGION="us-west-2"                    # e.g., us-west-2
NGINX_CONF="/etc/nginx/conf.d/codeartifact-proxy.conf"

# Optionally, set these via environment or edit above
DOMAIN="${DOMAIN:-$DOMAIN}"
REPO="${REPO:-$REPO}"
REGION="${REGION:-$REGION}"

set -e

echo "Refreshing CodeArtifact token..."
TOKEN=$(aws codeartifact get-authorization-token --domain "$DOMAIN" --region "$REGION" --query authorizationToken --output text)
if [ -z "$TOKEN" ]; then
	echo "Failed to fetch CodeArtifact token."
	exit 1
fi

# Encode token for Basic Auth
B64_TOKEN=$(echo -n "aws:$TOKEN" | base64)

# Update Nginx config with new token
if [ ! -f "$NGINX_CONF" ]; then
	echo "Nginx config not found: $NGINX_CONF"
	exit 1
fi

sudo sed -i.bak \
	"s|proxy_set_header Authorization \"Basic [^\"]*\";|proxy_set_header Authorization \"Basic $B64_TOKEN\";|" \
	"$NGINX_CONF"

echo "Reloading Nginx..."
sudo nginx -s reload
echo "Token updated and Nginx reloaded."
