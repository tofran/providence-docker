#!/bin/bash
set -exu

# DATABASE INIT/CONFIG
# TODO: Make it optional

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
# TODO: Understand why would one disable SSL
# --ssl-mode=DISABLED

#cd $CA_PROVIDENCE_DIR/media/ && mkdir collectiveaccess
#cd $CA_PROVIDENCE_DIR/media/collectiveaccess && mkdir -p tilepics
#cd $CA_PAWTUCKET_DIR && chown www-data:www-data . -R && chmod -R u+rX .
#cd $CA_PROVIDENCE_DIR && chown www-data:www-data . -R && chmod -R u+rX .

sweep() {
	sed -i "s@define(\"__CA_DB_HOST__\", 'localhost');@define(\"__CA_DB_HOST__\", \'$DB_HOST\');@g" setup.php
	sed -i "s@define(\"__CA_DB_USER__\", 'my_database_user');@define(\"__CA_DB_USER__\", \'$DB_USER\');@g" setup.php
	sed -i "s@define(\"__CA_DB_PASSWORD__\", 'my_database_password');@define(\"__CA_DB_PASSWORD__\", \'$DB_PW\');@g" setup.php
	sed -i "s@define(\"__CA_DB_DATABASE__\", 'name_of_my_database');@define(\"__CA_DB_DATABASE__\", \'$DB_NAME\');@g" setup.php
}

cd "$CA_PROVIDENCE_DIR"
sweep 'pro'

cd "$CA_PAWTUCKET_DIR"
sweep 'paw'

exec "$@"