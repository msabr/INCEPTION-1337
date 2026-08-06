#!/bin/bash
set -e

WP_PATH="/var/www/html"

read_secret() {
    local file_var_name="$1"
    local file_path="${!file_var_name}"
    if [ -n "$file_path" ] && [ -f "$file_path" ]; then
        cat "$file_path"
    fi
}

WORDPRESS_DB_PASSWORD="$(read_secret WORDPRESS_DB_PASSWORD_FILE)"
WP_ADMIN_PASSWORD="$(read_secret WP_ADMIN_PASSWORD_FILE)"
WP_USER_PASSWORD="$(read_secret WP_USER_PASSWORD_FILE)"

DB_HOST_ONLY="${WORDPRESS_DB_HOST%%:*}"

echo "[wordpress] Waiting for MariaDB (${DB_HOST_ONLY}) to be reachable..."
until mysqladmin ping -h "${DB_HOST_ONLY}" -u "${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent >/dev/null 2>&1; do
    sleep 2
done
echo "[wordpress] MariaDB is reachable."

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo "[wordpress] Downloading WordPress core..."
    wp core download --path="${WP_PATH}" --allow-root

    echo "[wordpress] Creating wp-config.php..."
    wp config create \
        --path="${WP_PATH}" \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --dbprefix="${WORDPRESS_TABLE_PREFIX:-wp_}" \
        --allow-root

    echo "[wordpress] Installing WordPress (skips the manual install page)..."
    wp core install \
        --path="${WP_PATH}" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE:-Inception}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "[wordpress] Creating a second, non-administrator user..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --path="${WP_PATH}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    chown -R www-data:www-data "${WP_PATH}"
    echo "[wordpress] Setup complete."
else
    echo "[wordpress] wp-config.php already exists, skipping setup."
fi

echo "[wordpress] Starting PHP-FPM in foreground..."
exec php-fpm8.2 -F
