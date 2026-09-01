FROM debian:bookworm

RUN apt update
RUN apt install -y mariadb-server

RUN sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/mariadb.sh /mariadb.sh
RUN chmod +x /mariadb.sh

ENTRYPOINT ["/mariadb.sh"]