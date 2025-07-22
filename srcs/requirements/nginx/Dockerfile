FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl gettext-base && apt-get clean

COPY /tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY conf /etc/nginx/conf.d

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD [ "nginx", "-g", "daemon off;"]
