#!/bin/bash
set -e

echo "Starting WordPress auto-configuration..."

# --- Wait for the database to be ready ---
# This loop will repeatedly try to connect to the database
# until it's successful, or a timeout is reached.
DB_HOST="$WORDPRESS_DB_HOST"
DB_NAME="$WORDPRESS_DB_NAME"
DB_USER="$WORDPRESS_DB_USER"
DB_PASSWORD="$WORDPRESS_DB_PASSWORD"

# Extract host and port from WORDPRESS_DB_HOST (e.g., "mariadb:3306")
DB_HOST_ONLY=$(echo "$DB_HOST" | cut -d':' -f1)
DB_PORT=$(echo "$DB_HOST" | cut -d':' -f2)

echo "Waiting for database at $DB_HOST_ONLY:$DB_PORT..."

# Loop to check for database readiness
for i in $(seq 1 30); do # Try for up to 300 seconds (30 * 10s intervals)
  # Check if the database host and port are reachable using netcat
  if nc -z "$DB_HOST_ONLY" "$DB_PORT" &>/dev/null; then
    echo "Database host:port reachable."
    # Now, try to connect to the MySQL service itself using the mysql client
    # This verifies the database server is ready and credentials are valid.
    # The `|| true` prevents the script from exiting if the mysql command fails initially.
    if mysql -h "$DB_HOST_ONLY" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" "$DB_NAME" &>/dev/null; then
      echo "Database service is ready and credentials are valid."
      break # Exit the loop if successful
    else
      echo "Database service not yet ready or credentials invalid, retrying in 10s..."
    fi
  else
    echo "Database host:port not reachable, retrying in 10s..."
  fi

  sleep 10 # Wait before the next attempt

  if [ "$i" -eq 30 ]; then
    echo "Timeout: Database did not become ready after 300 seconds. Exiting."
    exit 1 # Exit with an error if timeout reached
  fi
done

echo "Continuing with wp-config.php creation..."

cd /var/www/html

# Only create wp-config.php if it doesn't exist
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."

    # Check required env variables
    if [[ -z "$WORDPRESS_DB_NAME" || -z "$WORDPRESS_DB_USER" || -z "$WORDPRESS_DB_PASSWORD" || -z "$WORDPRESS_DB_HOST" ]]; then
        echo "Missing required environment variables: WORDPRESS_DB_NAME, WORDPRESS_DB_USER, WORDPRESS_DB_PASSWORD, WORDPRESS_DB_HOST"
        exit 1
    fi

    # Create wp-config.php using wp-cli if available, otherwise fallback to manual creation
    if command -v wp > /dev/null 2>&1; then
        echo "Using wp-cli to create config..."
        # Use DB_HOST directly as wp-cli expects it
        wp config create \
            --dbname="$WORDPRESS_DB_NAME" \
            --dbuser="$WORDPRESS_DB_USER" \
            --dbpass="$WORDPRESS_DB_PASSWORD" \
            --dbhost="$DB_HOST" \
            --allow-root
        echo "wp-cli config created successfully."
    else
        echo "wp-cli not found, creating wp-config.php manually..."
        # Manual config creation if wp-cli missing (basic version)
        # Generate unique salts for better security
        AUTH_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 64)
        SECURE_AUTH_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 64)
        LOGGED_IN_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 64)
        NONCE_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 64)
        AUTH_SALT=$(head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 64)
        SECURE_AUTH_SALT=$(head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 64)
        LOGGED_IN_SALT=$(head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 64)
        NONCE_SALT=$(head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 64)

        cat > wp-config.php <<EOF
<?php
define('DB_NAME', '$WORDPRESS_DB_NAME');
define('DB_USER', '$WORDPRESS_DB_USER');
define('DB_PASSWORD', '$WORDPRESS_DB_PASSWORD');
define('DB_HOST', '$DB_HOST');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY', '$AUTH_KEY');
define('SECURE_AUTH_KEY', '$SECURE_AUTH_KEY');
define('LOGGED_IN_KEY', '$LOGGED_IN_KEY');
define('NONCE_KEY', '$NONCE_KEY');
define('AUTH_SALT', '$AUTH_SALT');
define('SECURE_AUTH_SALT', '$SECURE_AUTH_SALT');
define('LOGGED_IN_SALT', '$LOGGED_IN_SALT');
define('NONCE_SALT', '$NONCE_SALT');

\$table_prefix = 'wp_';
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
EOF
        echo "Manual wp-config.php created successfully."
    fi

    # Set permissions so www-data can read/write wp-config.php
    echo "Setting permissions for wp-config.php..."
    chown www-data:www-data wp-config.php
    chmod 640 wp-config.php # Recommended permissions for wp-config.php
else
    echo "wp-config.php already exists, skipping creation"
fi

echo "WordPress auto-configuration complete. Executing container CMD..."
# Execute the container CMD (usually php-fpm)
exec "$@"

