FROM php:7.1-fpm-alpine
LABEL maintainer "Laurent Vergerolle <docker@ipeos.com>"

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
    imagemagick-dev \
    ${PHPIZE_DEPS} \
  && yes ""|pecl install imagick \
  && docker-php-ext-enable imagick \
  && apk del ${PHPIZE_DEPS}

# Active over php extension (mbstring and json already installed)
RUN apk --update --no-cache add \
    zlib-dev \
  && docker-php-ext-install zip opcache

# Install utils and remove apt cache
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

# Install spip-CLI

COPY install_composer.sh /install_composer.sh

RUN sh /install_composer.sh \
    && mv composer.phar /usr/local/bin/composer

RUN svn checkout svn://zone.spip.org/spip-zone/_outils_/spip-cli/trunk /opt/spip-cli \
    && cd /opt/spip-cli \
    && composer install \
    && ln -s /opt/spip-cli/bin/spip /usr/local/bin/spip 
#    && echo 'source /opt/spip-cli/bin/spip_console_autocomplete' > /root/.bashrc

# VOLUME ["/var/www/html"]

ENV SPIP_VERSION 3.2
ENV SPIP_PACKAGE 3.2.1

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

EXPOSE 80

COPY ./docker-entrypoint.sh /

#ENTRYPOINT ["sh /docker-entrypoint.sh"]
#ENTRYPOINT ["sh","/docker-entrypoint.sh"]

#CMD ["/bin/bash"]