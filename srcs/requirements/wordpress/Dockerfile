FROM debian:bookworm

# php8.2-fpm   : runs PHP code (WordPress is written in PHP) as its own process
# php8.2-mysql : lets PHP talk to MariaDB
# curl         : needed to download WordPress itself and the WP-CLI tool below
RUN apt-get update && apt-get install -y php8.2-fpm php8.2-mysql curl

RUN curl -sSL -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp
# WP-CLI: a command-line tool to install and configure WordPress without
# ever opening the browser install wizard (the grading sheet requires that
# you never see that wizard).

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/start.sh"]
