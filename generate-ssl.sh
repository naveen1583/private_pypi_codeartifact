#!/bin/bash
# Customize
DOMAIN_NAME="your-dns-name.example.com"

sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/proxy.key -out /etc/nginx/ssl/proxy.crt -subj "/CN=$DOMAIN_NAME"
echo "SSL cert generated for $DOMAIN_NAME"
