FROM debian:bookworm

# nginx        : the web server itself
# openssl      : to generate our own HTTPS certificate
# gettext-base : gives us `envsubst`, used below to insert the domain name into the config
RUN apt-get update && apt-get install -y nginx openssl gettext-base

COPY conf/nginx.conf.template /nginx.conf.template
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 443
ENTRYPOINT ["/start.sh"]
