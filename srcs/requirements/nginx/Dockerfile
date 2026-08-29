# dockerfile for nginx  conatainer 
FROM debian:bookworm

RUN  apt update &&  apt install -y nginx openssl && apt install -y netcat-openbsd

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -days 365 \
    -nodes \
    -subj "/CN=msabr.42.fr"

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY ./tools/nginx.sh /nginx.sh
RUN chmod +x /nginx.sh

ENTRYPOINT ["/nginx.sh"]