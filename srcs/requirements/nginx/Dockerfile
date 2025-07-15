FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl && apt-get clean

COPY /tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD [ "nginx", "-g", "daemon off;"]
