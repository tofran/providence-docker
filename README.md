# CollectiveAccess Providence Docker image

Production ready multi-arch Providence Docker image.
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
| `CA_DB_HOST`           | database host                                       |
| `CA_DB_DATABASE`       | database name                                       |
| `CA_DB_USER`           | database username                                   |
| `CA_DB_PASSWORD`       | database password                                   |
| `ENSURE_PERMISSIONS`   | `true` to chown files to the apache user            |

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