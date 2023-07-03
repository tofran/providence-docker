#!/bin/bash

set -eu

if [ "${INIT_DB:-false}" = true ] ; then
    echo -n "Initializing database..."

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
    
    echo " Databse initialization complete."
fi

mkdir -p "$CA_PROVIDENCE_DIR/media/collectiveaccess/tilepics"

if [ -z "$(ls -A "$CA_PROVIDENCE_DIR/app/conf")" ]; then
   echo "Providence configuration directory empty. Applying defaults."
   cp -r "$CA_PROVIDENCE_DIR/app/conf-default/"* "$CA_PROVIDENCE_DIR/app/conf"
fi

if [ "${ENSURE_PERMISSIONS-false}" = true ] ; then
    echo "Chowning providence installation to $APACHE_RUN_USER:$APACHE_RUN_GROUP"
    chown "$APACHE_RUN_USER":"$APACHE_RUN_GROUP" -R "$CA_PROVIDENCE_DIR"
fi

php_ini_path="$PHP_INI_DIR/php.ini"

sed -iE 's/^;\?\s*date.timezone\s\?=.*/date.timezone = Etc\/UTC/'          "$php_ini_path"
sed -iE 's/^;\?\s*expose_php\s\?=.*/expose_php = Off/'                     "$php_ini_path"
sed -iE 's/^;\?\s*memory_limit\s\?=.*/memory_limit = 1024M/'               "$php_ini_path"
sed -iE 's/^;\?\s*max_execution_time\s\?=.*/max_execution_time = 90/'      "$php_ini_path"
sed -iE 's/^;\?\s*post_max_size\s\?=.*/post_max_size = 800M/'              "$php_ini_path"
sed -ir 's/^;\?\s*upload_max_filesize\\s\?=.*/upload_max_filesize = 800M/' "$php_ini_path"
sed -iE 's/^;\?\s*max_input_vars\s\?=.*/max_input_vars = 1500/'            "$php_ini_path"

echo "Entrypoint setup complete. Running \"$*\""
exec "$@"
