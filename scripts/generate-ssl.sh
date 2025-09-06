
#!/usr/bin/env bash
# generate-ssl.sh - Generate a self-signed SSL certificate for Nginx proxy
#
# Usage: ./generate-ssl.sh <domain-name>
# Example: ./generate-ssl.sh pypi-proxy.example.com
#
# This script creates a self-signed certificate and key in /etc/nginx/ssl/.
#
# Arguments:
#   <domain-name>  The DNS name for the certificate's CN (Common Name)

set -e

DOMAIN_NAME="$1"
SSL_DIR="/etc/nginx/ssl"

if [ -z "$DOMAIN_NAME" ]; then
	echo "Usage: $0 <domain-name>"
	exit 1
fi

sudo mkdir -p "$SSL_DIR"

sudo openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 \
	-keyout "$SSL_DIR/proxy.key" \
	-out "$SSL_DIR/proxy.crt" \
	-subj "/CN=$DOMAIN_NAME"

echo "Self-signed certificate generated at $SSL_DIR/proxy.crt and $SSL_DIR/proxy.key."
