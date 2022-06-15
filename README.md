# CollectiveAccess providence

Production ready Providence Docker image forked from GovernoRegionalAcores/collectiveaccess.

# Fork goals

- Simplified installation, reduced docker layers, image size and unecessary conplexity;
- Removed Pawtucket;
- Reviwed all the code making it production ready;
- Allow to specify the CA version during build time;
- Allow all configuration via env vars;

# Statefull directories

- `/var/www/app/conf`: providance configuration
- `/var/www/media`: collective access media files

# Env vars

| Env var name         | description                                         |
| -------------------- | ----------------------------------------------------|
| INIT_DB              | true to create the database, user and permissions   |
| DB_ROOT_PASSWORD     | required to init the database                       |
| CA_DB_HOST           | database host                                       |
| CA_DB_DATABASE       | database name                                       |
| CA_DB_USER           | database username                                   |
| CA_DB_PASSWORD       | database password                                   |
| ENSURE_PERMISSIONS   | true to chown files to apache user                  |
