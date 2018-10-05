# Docker SPIP (Dual image version)

This project is a fork of IPEOS official Docker Spip [images set](https://hub.docker.com/r/ipeos/spip/).

There are several differences with original Docker image from IPEOS.

- There are two different images, one for Apache and one for PHP-FPM for better performances. Then the best way to use them is by using an orchestrator. This is adapted to  be used with Docker Compose or Docker Swarm (recommended), or any orchestrator such as Kubernetes, Rancher etc.
- Both images are based on Alpine Linux instead of Ubuntu. This results in thiner images (for instance for SPIP 3.2: 237MB plus 92MB - Total 329MB against 648MB for original image)
- There are two volumes: core and data. Core only contains distributed files and is erased each time a container is started. Data contains all content that can be written and modified, and is persistent.
- There is no use of .htaccess file, AllowOverride is set to false (following [this](https://httpd.apache.org/docs/2.4/howto/htaccess.html#when)). Instead, /var/www/html/data/htaccess.txt is used and included in Apache conf (and Apache doesn't start until this file is reachable). This file being in “data” volume, changes added by users are persistent.

As for original image, This docker use [SPIP-cli](https://contrib.spip.net/SPIP-Cli) project to manage an auto install for SPIP. It can be use to manage the SPIP with command line.

## Supported Tags Respective `Dockerfile` Links

Both for spip-web and spip-fpm images

- `3.2`, `latest`
- `3.1`
- `3.0`
- `2.1`

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/ipeos/spip/).

Recommanded way is to download docker-compose.yml and .env file both located in compose_samples directory. Save the in the same local directory. They are usable as it, but you can edit both files to suit your needs. By default, latest SPIP release is downloaded and volumes are used for core and data (plus another volume for database)

## Quick Start

First create volumes spip-core spip-data and spip-db
```bash
docker volume create spip-core && docker volume create spip-data && docker volume create spip-db
```
Initiate docker swarm
```bash
docker swarm init
```
Deploy stack
```bash
docker stack deploy -c docker-compose.yml docker-spip
```

## Available Environment Vars

All these environment vars can be set in .env file.

**Auto-install is only available on SPIP 3.X versions**

- `SPIP_DB_SERVER`: connexion method to the database `sqlite3` or `mysql` (default: `mysql`)
- `SPIP_DB_PREFIX`: SQL table preffix (default: `spip`)

### For MySQL Database Only

**The MySQL database must exist before installation. It will not be automatically created.**

- `SPIP_DB_HOST`: MySQL server hostname or IP (default: `mysql`)
- `SPIP_DB_LOGIN`: MySQL user login (default: `spip`)
- `SPIP_DB_PASS`: MySQL user password (default: `spip`)
- `SPIP_DB_NAME`: MySQL database name (default: `spip`)

### Admin Account

- `SPIP_ADMIN_NAME`: account name (default: `Admin`)
- `SPIP_ADMIN_LOGIN`: account login (default: `admin`)
- `SPIP_ADMIN_EMAIL`: account email (default: `admin@spip`)
- `SPIP_ADMIN_PASS`: account password (default: `adminadmin`)

### PHP Vars

Can change PHP vars to optimize your installation.

- `PHP_MAX_EXECUTION_TIME` (default: `60`)
- `PHP_MEMORY_LIMIT` (default: `256M`)
- `PHP_POST_MAX_SIZE` (default: `40M`)
- `PHP_UPLOAD_MAX_FILESIZE` (default `32M`)
- `PHP_TIMEZONE` (default: `America/Guadeloupe`)

## Contributing

If you find this image useful here's how you can help:

* Send a Pull Request with your awesome enhancements and bug fixes
* Be a part of the community and help resolve Issues

## Team

* [Raphaël Jadot](https://github.com/ashledombos/)

### IPEOS

* [Laurent Vergerolle](https://github.com/psychoz971/)
* [Olivier Watté](https://github.com/owatte/)
