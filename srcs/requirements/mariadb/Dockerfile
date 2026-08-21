# Base OS — the project requires Debian or Alpine, not a ready-made database image.
FROM debian:bookworm

# Install only the database server itself.
RUN apt-get update && apt-get install -y mariadb-server

# A one-line config change (see conf/bind.cnf) so MariaDB accepts
# connections from other containers, not just from itself.
COPY conf/bind.cnf /etc/mysql/mariadb.conf.d/bind.cnf

# Our startup script — see tools/init_db.sh.
COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306
# Run our script as PID 1 (required: no shell wrapper, no background process).
ENTRYPOINT ["/init_db.sh"]
