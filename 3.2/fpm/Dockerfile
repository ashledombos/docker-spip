FROM alpine:latest as pngnq-s9
LABEL maintainer "Raphaël Jadot"

# Compile pngnq-s9 in which is a useful library (used by smush plugin)
WORKDIR /
RUN apk --update add \
    build-base \
    gcc \
    abuild \
    binutils \
    libpng-dev
RUN curl -sL -o- "https://sourceforge.net/projects/pngnqs9/files/pngnq-s9-2.0.2.tar.gz" |tar -xz \
    && cd pngnq-s9-2.0.2 \
    && ./configure \
    && make

# new build stage
FROM php:7.1-fpm-alpine
COPY --from=pngnq-s9 /pngnq-s9-2.0.2/src/pngnq-s9 /usr/local/bin/pngnq


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
  
# Install additional image tools
RUN apk --update --no-cache add \
    optipng \
    gifsicle
    
# Install Redis
RUN pecl bundle -d /usr/src/php/ext redis \
    && rm /usr/src/php/ext/redis-*.tgz \
    && docker-php-ext-install redis

# Active over php extension (mbstring and json already installed)
RUN apk --update --no-cache add \
    zlib-dev \
  && docker-php-ext-install zip opcache

# Install utils and remove apt cache (no need to clean cache as we used --no-cache)
RUN apk --update --no-cache add \
    unzip \
    gettext \
    subversion

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
RUN php -r "readfile('http://getcomposer.org/installer');" \
    | php -- --install-dir=/usr/local/bin/ --filename=composer --no-plugins --no-scripts \
    && svn checkout svn://zone.spip.org/spip-zone/_outils_/spip-cli/trunk /opt/spip-cli \
    && rm -rf /opt/spip-cli/.svn \
    && cd /opt/spip-cli \
    && composer install \
    && ln -s /opt/spip-cli/bin/spip /usr/local/bin/spip
    
VOLUME ["/var/www/html/core/"]
VOLUME ["/var/www/html/data/"]

ENV SPIP_VERSION 3.2
ENV SPIP_PACKAGE 3.2.7


# Install SPIP
RUN set -ex; \
  curl -o spip.zip -fSL "files.spip.net/spip/archives/SPIP-v${SPIP_PACKAGE}.zip"; \
  unzip spip.zip -d /usr/src/; \
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
