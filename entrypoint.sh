#!/bin/bash
set -eu

echo "Setting up Collective Access..."

if [ "$INIT_DB" = true ] ; then
    mysql \
        --host="$DB_HOST" \
        --user="root" \
        --password="$DB_ROOT_PASSWORD" \
        --execute="
            CREATE DATABASE IF NOT EXISTS $DB_NAME;
            CREATE USER IF NOT EXISTS '$DB_USER';
            ALTER USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PW';
            GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER';
            FLUSH PRIVILEGES;
        "
fi

mkdir -p "$CA_PROVIDENCE_DIR/media/collectiveaccess/tilepics"
chown "$APACHE_RUN_USER":"$APACHE_RUN_USER" -R "$CA_PROVIDENCE_DIR"

sed -i "s@Options Indexes FollowSymLinks@Options@g" /etc/apache2/apache2.conf

define_envs() {
    sed -i "s@define(\"__CA_DB_HOST__\", 'localhost');@define(\"__CA_DB_HOST__\", \"$DB_HOST\");@g" "$1"
    sed -i "s@define(\"__CA_DB_USER__\", 'my_database_user');@define(\"__CA_DB_USER__\", \"$DB_USER\");@g" "$1"
    sed -i "s@define(\"__CA_DB_PASSWORD__\", 'my_database_password');@define(\"__CA_DB_PASSWORD__\", \"$DB_PW\");@g" "$1"
    sed -i "s@define(\"__CA_DB_DATABASE__\", 'name_of_my_database');@define(\"__CA_DB_DATABASE__\", \"$DB_NAME\");@g" "$1"
}

define_envs "$CA_PROVIDENCE_DIR/setup.php"

echo "Starting \"$*\""
exec "$@"