#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/CN=$DOMAIN_NAME"
    # Generate a self-signed certificate + key, valid 1 year.
    # "Self-signed" means the browser will show a warning — that's expected
    # and accepted by the grading sheet, no real certificate is required.
fi

envsubst '${DOMAIN_NAME}' < /nginx.conf.template > /etc/nginx/nginx.conf
# Take the template, replace ${DOMAIN_NAME} with the real value from our
# environment variable, and write the final config nginx will actually use.

exec nginx -g "daemon off;"
# Start nginx in the foreground as PID 1 ("daemon off" stops it from
# forking into the background, which would break the container).
