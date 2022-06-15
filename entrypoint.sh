#!/bin/bash

set -eu

if [ "${INIT_DB:-false}" = true ] ; then
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

mkdir -p "$CA_PROVIDENCE_DIR/media/collectiveaccess/tilepics"

if [ "${ENSURE_PERMISSIONS-false}" = true ] ; then
    echo "ChOwning providence installation to $APACHE_RUN_USER:$APACHE_RUN_GROUP"
    chown "$APACHE_RUN_USER":"$APACHE_RUN_GROUP" -R "$CA_PROVIDENCE_DIR"
fi

if [ -z "$(ls -A "$CA_PROVIDENCE_DIR/app/conf")" ]; then
   echo "Providence configuration directory empty. Applying defaults."
   cp -r "$CA_PROVIDENCE_DIR/app/conf-default" "$CA_PROVIDENCE_DIR/app/conf"
fi

echo "Running \"$*\""
exec "$@"
