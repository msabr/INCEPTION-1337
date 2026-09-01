#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe & 
until mysqladmin ping --silent; do
	sleep 1
done

mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"

mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';"

mysql -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';"

mysqladmin shutdown
until ! mysqladmin ping --silent; do
	sleep 1
done

exec mysqld_safe