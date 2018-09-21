#!/bin/bash
set -e

# Reconfigure php.ini
# set PHP.ini settings for SPIP
( \
echo 'display_errors=Off'; \
echo 'error_log=/var/log/apache2/php.log'; \
echo 'max_execution_time=${PHP_MAX_EXECUTION_TIME}'; \
echo 'memory_limit=${PHP_MEMORY_LIMIT}'; \
echo 'post_max_size=${PHP_POST_MAX_SIZE}'; \
echo 'upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE}'; \
echo 'date.timezone=${PHP_TIMEZONE}'; \
) > /usr/local/etc/php/conf.d/spip.ini

exec "$@"
