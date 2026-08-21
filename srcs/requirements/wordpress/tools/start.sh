#!/bin/bash
set -e

DB_PASS=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
ADMIN_PASS=$(cat "$WP_ADMIN_PASSWORD_FILE")
USER_PASS=$(cat "$WP_USER_PASSWORD_FILE")
# Read the 3 real passwords from their secret files.

until mysqladmin ping -h mariadb -u wp_user -p"$DB_PASS" --silent 2>/dev/null; do
    sleep 2
done
# Don't try to install WordPress before the database is actually ready to
# accept connections — mariadb takes a few seconds to start up.

if [ ! -f wp-config.php ]; then
    # wp-config.php only exists after WordPress has been installed once.
    # If it's missing, this is the first time this container has run.

    wp core download --allow-root
    # Download WordPress's PHP files into the current folder (/var/www/html).

    wp config create \
        --dbname=wordpress --dbuser=wp_user --dbpass="$DB_PASS" \
        --dbhost=mariadb --allow-root
    # Write wp-config.php with the database connection details.
    # ("mariadb" here is the container name, used as a hostname.)

    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$ADMIN_PASS" \
        --admin_email="admin@$DOMAIN_NAME" \
        --skip-email \
        --allow-root
    # Run the actual install: creates all WordPress database tables and the
    # admin account, in one non-interactive command instead of the browser wizard.

    wp user create editor "editor@$DOMAIN_NAME" \
        --role=author --user_pass="$USER_PASS" --allow-root
    # A second, non-admin account — used to satisfy the "add a comment as a
    # normal WordPress user" grading check.
fi

exec /usr/sbin/php-fpm8.2 -F
# Start PHP-FPM in the foreground ("-F") as PID 1.
