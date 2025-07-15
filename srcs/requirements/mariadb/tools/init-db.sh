#!/bin/bash
set -e

# Start MariaDB temporarily for initialization
mysqld_safe --skip-networking &

# Wait until MariaDB is ready by trying a simple command with password
until mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" > /dev/null 2>&1; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

echo "MariaDB started!"

# Run your initialization SQL commands
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

# Shutdown the temporary server
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Finally, execute the main command (e.g., start MariaDB normally)
exec "$@"

