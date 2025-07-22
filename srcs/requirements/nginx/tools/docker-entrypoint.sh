#!/bin/sh

# Paths to SSL files
CERT_PATH=/etc/nginx/ssl/${DOMAIN_NAME}.crt
KEY_PATH=/etc/nginx/ssl/${DOMAIN_NAME}.key

# Check if cert files exist; if not, generate self-signed cert
if [ ! -f "$CERT_PATH" ] || [ ! -f "$KEY_PATH" ]; then
    echo "Generating self-signed SSL certificate..."
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 \
      -newkey rsa:2048 \
      -keyout "$KEY_PATH" \
      -out "$CERT_PATH" \
      -subj "/CN=${DOMAIN_NAME}/O=Self-Signed/C=FR"
fi

envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"
