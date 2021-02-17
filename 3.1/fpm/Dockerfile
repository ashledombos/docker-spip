FROM php:7.1-fpm-alpine
LABEL maintainer "Raphaël JADOT <rj+spip@hodo.fr>"

# Install ghostscript
RUN apk --update --no-cache add \
  ghostscript

# Install mcrypt
RUN apk --update --no-cache add \
    libmcrypt-dev \
  && docker-php-ext-install mcrypt

# Install gd
RUN apk --update --no-cache add \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd

# Install mysql (sqlite is already installed)
RUN apk --update --no-cache add \
    mariadb-client \
  && docker-php-ext-install mysqli

# Install curl (curl already installed)

# Install Imagick
RUN apk --update --no-cache add \
    imagemagick \
    imagemagick-dev \
    ${PHPIZE_DEPS} \
  && yes ""|pecl install imagick \
  && docker-php-ext-enable imagick \
  && apk del ${PHPIZE_DEPS}
  
# Install Redis
#RUN apk --update --no-cache add \
#    ${PHPIZE_DEPS} \
#    yes ""|pecl install -o -f redis \
#    &&  rm -rf /tmp/pear \
#    &&  docker-php-ext-enable redis \
#    && apk del ${PHPIZE_DEPS}

# Active over php extension (mbstring and json already installed)
RUN apk --update --no-cache add \
    zlib-dev \
  && docker-php-ext-install zip opcache

# Install utils and remove apt cache (no need to clean cache as we used --no-cache)
RUN apk --update --no-cache add \
    unzip \
    gettext \
    git

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=0'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Active apache rewrite mode
# (as it's not ubuntu a2enmode doesn't work. Instead we activate the module in spip.apache.conf)

# Install SPIP-Cli (Composer is now needed)
#RUN php -r "readfile('http://getcomposer.org/installer');" \
#    | php -- --install-dir=/usr/local/bin/ --filename=composer --no-plugins --no-scripts \
#    && svn checkout svn://zone.spip.org/spip-zone/_outils_/spip-cli/trunk /opt/spip-cli \
#    && rm -rf /opt/spip-cli/.svn \
#    && cd /opt/spip-cli \
#    && composer install \
#    && ln -s /opt/spip-cli/bin/spip /usr/local/bin/spip
    
# Install SPIP-Cli
RUN cd /opt; \
  curl --silent --show-error https://getcomposer.org/installer | php

RUN git clone https://git.spip.net/spip-contrib-outils/spip-cli.git /opt/spip-cli; \
  rm -rf /opt/spip-cli/.git; \
  rm -rf /opt/spip-cli/.gitattributes; \
  rm -rf /opt/spip-cli/.gitignore; \
  ln -s /opt/spip-cli/bin/spip /usr/local/bin/spip; \
  ln -s /opt/spip-cli/bin/spipmu /usr/local/bin/spipmu;

RUN cd /opt/spip-cli && /opt/composer.phar install
    
VOLUME ["/var/www/html/core/"]
VOLUME ["/var/www/html/data/"]

ENV SPIP_VERSION 3.1
ENV SPIP_PACKAGE 3.1.15


# Install SPIP
RUN set -ex; \
  curl -o spip.zip -fSL "files.spip.net/spip/archives/spip-v${SPIP_PACKAGE}.zip"; \
  mkdir /usr/src/spip; \
  unzip spip.zip -d /usr/src/spip/; \
  rm spip.zip; \
  chown -R www-data:www-data /usr/src/spip

# SPIP
ENV SPIP_DB_SERVER mysql
ENV SPIP_DB_HOST mysql
ENV SPIP_DB_LOGIN spip
ENV SPIP_DB_PASS spip
ENV SPIP_DB_NAME spip
ENV SPIP_DB_PREFIX spip
ENV SPIP_ADMIN_NAME Admin
ENV SPIP_ADMIN_LOGIN admin
ENV SPIP_ADMIN_EMAIL admin@spip
ENV SPIP_ADMIN_PASS adminadmin

# PHP
ENV PHP_MAX_EXECUTION_TIME 60
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_POST_MAX_SIZE 40M
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_TIMEZONE America/Guadeloupe

EXPOSE 9000

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["sh","/docker-entrypoint.sh"]

CMD ["php-fpm"]
