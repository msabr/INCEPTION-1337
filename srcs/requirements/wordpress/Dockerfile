FROM debian:bookworm

RUN apt update && apt install -y php php-fpm php-mysql mariadb-client curl

RUN curl -O https://wordpress.org/wordpress-7.1.tar.gz \
    && tar -xf wordpress-7.1.tar.gz -C /var/www/html/

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp-cli.phar

RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/wordpress.sh /wordpress.sh
RUN chmod +x /wordpress.sh

ENTRYPOINT ["/wordpress.sh"]

CMD ["php-fpm8.2", "-F"]