#!/bin/bash
set -e

: "${DOMAIN_NAME:=localhost}"

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "[nginx] Generating self-signed TLS certificate for ${DOMAIN_NAME}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}"
    chmod 600 /etc/nginx/ssl/nginx.key
    chmod 644 /etc/nginx/ssl/nginx.crt
else
    echo "[nginx] TLS certificate already exists, skipping generation."
fi

echo "[nginx] Rendering config for domain ${DOMAIN_NAME}..."
envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "[nginx] Testing configuration..."
nginx -t

echo "[nginx] Starting NGINX in foreground..."
exec nginx -g "daemon off;"
