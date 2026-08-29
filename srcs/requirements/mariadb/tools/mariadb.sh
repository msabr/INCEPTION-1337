#!/bin/bash

mysqld_safe --skip-networking &

until mysqladmin ping --silent; do
    sleep 1
done

mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

mysql -e "CREATE USER IF NOT EXISTS '$USER_NAME'@'%' IDENTIFIED BY '$DB_USER_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$USER_NAME'@'%';"


mysqladmin shutdown

exec mysqld_safe