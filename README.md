# CollectiveAccess Providence Docker image

Production ready multi-arch up-to-date Providence Docker image.

[Providence] is a dynamic cataloguing and data/media management application
(widely used by museums), part of the [CollectiveAccess] project.

`docker pull ghcr.io/tofran/providence`

OR

`docker pull tofran/providence`

## Configuration

### Environment variables

| Env var name           | Description                                         |
| ---------------------- | ----------------------------------------------------|
| `INIT_DB`              | `true` to create the database, user and permissions |
| `DB_ROOT_PASSWORD`     | required if `INIT_DB` is set                        |
| `CA_DB_HOST`           | MariaDB (or MySQL) database host                    |
| `CA_DB_DATABASE`       | MariaDB (or MySQL) database name                    |
| `CA_DB_USER`           | MariaDB (or MySQL) database username                |
| `CA_DB_PASSWORD`       | MariaDB (or MySQL) database password                |
| `ENSURE_PERMISSIONS`   | `true` to chown data files to the apache user       |

### Stateful directories

The following directories are not ephemeral and should be preserved:

- `/var/www/app/conf`: Providence configuration
- `/var/www/media`: Collective access media files

## Attribution and acknowledgement

This image is based on the stale project created by 
[Governo Regional dos Açores](https://github.com/GovernoRegionalAcores/collectiveaccess).
Thank you Alberto Branco and Pedro Amorim.
This is a hard fork, the main changes are:

- Simplified installation, reduced docker layers, image size and unnecessary complexity;
- Removed Pawtucket, I only want a single component in this image;
- Enable configuration via environment variables;
- Improved scripts resiliency, code smells and overall tried to make everything production ready.


[Providence]: https://github.com/collectiveaccess/providence/
[CollectiveAccess]: https://www.collectiveaccess.org