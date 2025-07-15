# Basic OS image
FROM debian:bullseye

# Install PHP-FPM, MySQL client, wget, unzip, tar, curl, netcat
# Added 'netcat-traditional' to support the 'nc' command in auto-config.sh
RUN apt-get update && apt-get install -y \
    php7.4-fpm php7.4-mysql wget unzip tar curl net-tools default-mysql-client netcat-traditional \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create /run/php and assign ownership to www-data user (PHP-FPM requirement)
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

# Download and extract WordPress into /var/www/html
RUN mkdir -p /var/www/html && \
    wget https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz && \
    tar -xzf /tmp/latest.tar.gz --strip-components=1 -C /var/www/html && \
    rm /tmp/latest.tar.gz && \
    chown -R www-data:www-data /var/www/html

# Copy custom PHP-FPM pool config (adjust if needed)
COPY /tools/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy auto-config shell script and make executable
COPY /tools/auto-config.sh /usr/local/bin/auto-config.sh
RUN chmod +x /usr/local/bin/auto-config.sh

# Expose PHP-FPM port
EXPOSE 9000

# Use ENTRYPOINT to run the auto-config script on container start
ENTRYPOINT ["/usr/local/bin/auto-config.sh"]

# Default command to run php-fpm in the foreground
CMD ["php-fpm7.4", "-F"]

