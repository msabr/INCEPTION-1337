#!/bin/bash
set -e
# Stop the script immediately if any command below fails,
# instead of continuing and hiding the real error.

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
# MariaDB needs this folder (for its socket file) and needs to own it.

DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
# Read the real password out of the secret file. It is never written into
# this script, an image layer, or docker-compose.yml — only its file PATH is.

if [ ! -d "/var/lib/mysql/mysql" ]; then
    # This folder only exists after MariaDB has been set up once.
    # If it's missing, this is the container's first ever boot.

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    # Create MariaDB's internal system tables.

    mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --user=mysql &
    pid=$!
    # Start MariaDB temporarily, in the background, with networking OFF,
    # just so we can create our database and user. $! = its process ID.

    until mysqladmin --socket=/run/mysqld/mysqld.sock ping 2>/dev/null; do
        sleep 1
    done
    # Wait (checking once a second) until that temporary server is ready.

    mysql --socket=/run/mysqld/mysqld.sock -u root <<-SQL
        CREATE DATABASE $MYSQL_DATABASE;
        CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
        GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
SQL
    # Create the WordPress database and a user allowed to use it from
    # any host ('%'), since WordPress connects from a different container.

    mysqladmin --socket=/run/mysqld/mysqld.sock -u root shutdown
    wait "$pid"
    # Stop the temporary server and wait for it to fully exit before continuing.
fi

exec mysqld --user=mysql
# Start MariaDB for real, in the FOREGROUND, replacing this script as PID 1.
# ("exec" is what makes this PID 1 instead of a background process —
# required by the subject.)
