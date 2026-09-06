#!/bin/bash

mkdir -p /var/www/html/wordpress && chown -R www-data:www-data /var/www/html/wordpress 
cd /var/www/html/wordpress

until mysqladmin ping -h mariadb -u"$DB_USER" -p"$DB_USER_PASS" --silent; do
	echo "waiting for MariaDB..."
	sleep 1
done
echo "MariaDB is ready!"

if [ ! -f wp-config.php ]; then
	wp-cli.phar config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_USER_PASS" --dbhost=mariadb:3306 --allow-root
	wp-cli.phar core install --url="$URL" --title="inception" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_EMAIL" --allow-root
	wp-cli.phar user create "$WP_USER_NAME" "$WP_USER_EMAIL" --role=subscriber --user_pass="$WP_USER_PASS" --allow-root
fi

exec "$@"