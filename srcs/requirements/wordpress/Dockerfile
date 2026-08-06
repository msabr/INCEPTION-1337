FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-intl \
    php8.2-mbstring \
    php8.2-soap \
    php8.2-xml \
    php8.2-zip \
    curl \
    less \
    default-mysql-client \
    ca-certificates \
    && ln -s /usr/sbin/php-fpm8.2 /usr/local/bin/php-fpm \
    && rm -rf /var/lib/apt/lists/*

# WP-CLI is used to install/configure WordPress non-interactively (no manual install wizard).
RUN curl -o /usr/local/bin/wp -sSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

WORKDIR /var/www/html

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup_wordpress.sh /usr/local/bin/setup_wordpress.sh
RUN chmod +x /usr/local/bin/setup_wordpress.sh

EXPOSE 9000

ENTRYPOINT ["setup_wordpress.sh"]
