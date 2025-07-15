FROM debian:bullseye

#set environment variable for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

#update and install MariaDB
RUN apt-get update -y && apt-get install -y mariadb-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
#create a directory for MariaDB data if needed
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld
    
#allow external access
RUN chmod +x /var/run/mysqld

COPY /tools/mariadb.cnf /etc/mysql/conf.d/mariadb.cnf

COPY /tools/init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-db.sh

#default Mysql port
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init-db.sh"]
CMD ["mysqld", "--bind-address=0.0.0.0"] 

