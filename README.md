# CollectiveAccess providence

Simple (quite big tho) providence docker image forked from GovernoRegionalAcores/collectiveaccess.

# Fork goals

- Simplified installation, reduced docker layers, image size and unecessary conplexity;
- Removed Pawtucket;
- Reviwed all the code making it production ready;
- Allow to specify the CA version during build time;
- Allow all configuration via env vars;

# Statefull directories

- `/var/www/app/conf`: providance configuration
- `/var/www/media`: collective access media files
