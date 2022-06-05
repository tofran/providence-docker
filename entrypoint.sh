#!/bin/bash

set -eu

echo "Setting up Collective Access..."

mkdir -p "$CA_PROVIDENCE_DIR/media/collectiveaccess/tilepics"
chown "$APACHE_RUN_USER":"$APACHE_RUN_USER" -R "$CA_PROVIDENCE_DIR"

if [ "$INIT_DB" = true ] ; then
    echo "Initializing database"

    mysql \
        --host="$CA_DB_HOST" \
        --user="root" \
        --password="$DB_ROOT_PASSWORD" \
        --execute="
            CREATE DATABASE IF NOT EXISTS $CA_DB_DATABASE;
            CREATE USER IF NOT EXISTS '$CA_DB_USER';
            ALTER USER '$CA_DB_USER'@'%' IDENTIFIED BY '$CA_DB_PASSWORD';
            GRANT ALL PRIVILEGES ON $CA_DB_DATABASE.* TO '$CA_DB_USER';
            FLUSH PRIVILEGES;
        "
fi

echo "Running \"$*\""
exec "$@"
