#!/bin/sh

# Paths to SSL files
CERT_PATH=/etc/nginx/ssl/snegi.42.fr.crt
KEY_PATH=/etc/nginx/ssl/snegi.42.fr.key

# Check if cert files exist; if not, generate self-signed cert
if [ ! -f "$CERT_PATH" ] || [ ! -f "$KEY_PATH" ]; then
    echo "Generating self-signed SSL certificate..."
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 \
      -newkey rsa:2048 \
      -keyout "$KEY_PATH" \
      -out "$CERT_PATH" \
      -subj "/CN=snegi.42.fr/O=Self-Signed/C=FR"
fi

exec "$@"
