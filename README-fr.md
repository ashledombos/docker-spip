# Docker SPIP (version double image)

Ce projet est un fork des [images Docker officielles](https://hub.docker.com/r/ipeos/spip/) de SPIP par IPEOS.

Plusieurs différences spécifient ces images par rapport à celles d'IPEOS.

- Il y a deux images différentes, une pour Apache et une pour PHP-FPM. L'utilisation de ces images est donc plus adaptée en conjonction avec Docker Compose ou Docker Swarm, ou tout autre orchestrateur tel que Kubernetes, Rancher etc.
- Les deux images sont basées sur Alpine Linux au lieu d'Ubuntu. Il en résulte des images plus petites (par exemple pour SPIP 3.2 : 237MB plus 92MB - Total 329MB contre 648MB pour l'image originale)
- Il y a deux volumes : core et data. Le répertoire «core» ne contient que des fichiers de la distribution de SPIP et est effacé chaque fois que le conteneur PHP est redémarré. Le répertoire «data» contient tout le contenu qui peut être écrit et modifié, et est persistant.
- Il n'y a pas d'utilisation du fichier .htaccess, AllowOverride est réglé sur false (suivant cette [recommandation](https://httpd.apache.org/docs/2.4/howto/htaccess.html#when)). À la place, /var/www/html/html/data/htaccess.txt est utilisé et inclus dans Apache conf (et Apache ne démarre que lorsque ce fichier est accessible). Ce fichier étant dans le volume "données", les changements ajoutés par les utilisateurs sont persistants.

Comme pour l'image originale, ce docker utilise le projet [SPIP-cli](https://contrib.spip.net/SPIP-Cli) pour gérer une installation automatique pour SPIP. Il peut être utilisé pour gérer le SPIP en ligne de commande.

## Liens `Dockerfile` de Tags Supportés Respectivement

Pour les images spip-web et spip-fpm

- "3.2", "latest".
- `3.1`
- `3.0`
- `2.1`

## Installation

Des versions générées automatiquement de l'image sont disponibles sur [Docker Hub](https://hub.docker.com/r/ipeos/spip/).

Des fichiers d'exemples docker-compose sont disponibles dans le répertoire compose_samples.

## Quick Start

Créez d'abord les volumes spip-core spip-data et spip-db

```bash
docker volume create spip-core && docker volume create spip-data && docker volume create spip-db
```
Initialisation de l'essaim de dockers
```bash
docker swarm init
```
Déployer la pile
```bash
docker stack deploy -c docker-compose.yml docker-spip
```
Si vous n'exposez pas de ports, et choisissez d'utiliser træfik, lancez celui-ci

```bash
docker stack deploy -c docker-compose.traefik.yml traefik
```


## Variables d'environnement

Toutes ces variables d'environnement peuvent être définies dans le fichier.env.

L'installation automatique n'est disponible que sur les versions SPIP 3.X****.

- `SPIP_DB_SERVER` : méthode de connexion à la base de données `sqlite3` ou `mysql` (par défaut : `mysql`)
- `SPIP_DB_PREFIX` : Préfixe de la table SQL (par défaut : `spip`)

### Pour la base de données MySQL uniquement

**La base de données MySQL doit exister avant l'installation, l'ordre de lancement des services est donc important.**

- `SPIP_DB_HOST` : Nom d'hôte du serveur MySQL ou IP (par défaut : `mysql`)
- `SPIP_DB_LOGIN` : Connexion utilisateur MySQL (par défaut : `spip`)
- `SPIP_DB_PASS` : Mot de passe utilisateur MySQL (par défaut : `spip`)
- `SPIP_DB_NAME` : Nom de la base de données MySQL (par défaut : `spip`)

#### Compte Admin

- `SPIP_ADMIN_NAME` : nom du compte (par défaut : `Admin`)
- `SPIP_ADMIN_LOGIN` : login du compte (par défaut : `admin`)
- `SPIP_ADMIN_EMAIL` : email du compte (par défaut : `admin@spip`)
- `SPIP_ADMIN_PASS` : mot de passe du compte (par défaut : `adminadmin`)

#### Variables PHP

Optmisation des variables PHP

- `TEMPS_MAX_EXECUTION_TIME` (par défaut : `60`)
- `PHP_MEMORY_LIMIT` (par défaut : `256M`)
- `PHP_POST_MAX_SIZE` (par défaut : `40M`)
- `PHP_UPLOAD_MAX_FILESIZE` (par défaut `32M`)
- `PHP_TIMEZONE` (par défaut : `Amérique / Guadeloupe`)

## Équipe

*[Raphaël Jadot](https://github.com/ashledombos/)

#### IPEOS

*[Laurent Vergerolle](https://github.com/psychoz971/)
*[Olivier Watté](https://github.com/owatte/)
