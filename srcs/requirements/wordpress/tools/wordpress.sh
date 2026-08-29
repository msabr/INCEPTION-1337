#!/bin/bash

cd /var/www/html/wordpress

until mysqladmin ping -h mariadb -u"$USER_NAME" -p"$DB_USER_PASS" --silent
do
    echo "tssna MariaDB tssna ..."
    sleep 1
done
echo "MariaDB is ready!"


if [ ! -f /var/www/html/wordpress/wp-config.php ]; then
    wp config create --dbname=$DB_NAME --dbuser=$USER_NAME  --dbpass=$DB_USER_PASS --dbhost=mariadb:3306  --allow-root
    wp core install --url=$URL --title=Inception --admin_user=$WP_AD_USER --admin_password=$WP_PS_USER --admin_email=$WP_USER_EMAIL --allow-root
    wp user create $WP_USER $WP_EMAIL  --role=subscriber --user_pass=$WP_PASS --allow-root
fi

exec "$@"