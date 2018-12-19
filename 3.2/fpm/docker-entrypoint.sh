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

# Separate the core of SPIP and data
# Copy SPIP core to shared volume.
echo >&2 "Setting SPIP core in $PWD/core/"
rm -Rf /var/www/html/core/*
tar cf - --one-file-system -C /usr/src/spip . | tar xf - -C core
echo >&2 "Complete! SPIP has been successfully copied to $PWD/core/"

# IMG and config will be modified so let's move it to data volume
echo >&2 "Move IMG and config in $PWD/data/ if needed"
if [ ! -d data/IMG ]; then
  mv core/IMG data/
else
  rm -Rf core/IMG/
fi
if [ ! -d data/config ]; then
  mv core/config data/
else
  rm -Rf core/config
fi

# For better performance, we include the content of htaccess.txt in apache conf
echo >&2 "Apache uses $PWD/data/htaccess.txt instead of .htaccess"
if [ ! -e data/htaccess.txt ]; then
  mv core/htaccess.txt data/htaccess.txt
else
  rm core/htaccess.txt
fi

# All necessary directories should be created if they aren't yet
echo >&2 "Create plugins, libraries and template directories in $PWD/data/ if they don't exist"
mkdir -p data/plugins/auto
mkdir -p data/lib
mkdir -p data/squelettes
mkdir -p data/tmp/dump
mkdir -p data/tmp/log
mkdir -p data/tmp/upload

echo >&2 "change rights"
chown -R www-data:www-data data/IMG data/config data/plugins data/lib data/squelettes data/htaccess.txt data/tmp

# As core directory is the webroot directory, we link all subdirectories from data volume
echo >&2 "create all symlinks"
ln -s $PWD/data/IMG core/
ln -s $PWD/data/config core/
ln -s $PWD/data/plugins core/
ln -s $PWD/data/lib core/
ln -s $PWD/data/squelettes core/
ln -s $PWD/data/htaccess.txt core/
ln -s $PWD/data/tmp/dump core/tmp/
ln -s $PWD/data/tmp/log core/tmp/
ln -s $PWD/data/tmp/upload core/tmp/



# Install SPIP
if [ ! -e data/config/connect.php ]; then
	# Wait for mysql before install
	# cf. https://docs.docker.com/compose/startup-order/
	if [ ${SPIP_VERSION} == '3.2' ] || [ ${SPIP_VERSION} == '3.1' ] || [ ${SPIP_VERSION} == '3.0' ]; then
		if [ ${SPIP_DB_SERVER} = "mysql" ]; then
			until mysql -h ${SPIP_DB_HOST} -u ${SPIP_DB_LOGIN} -p${SPIP_DB_PASS}; do
			  >&2 echo "mysql is unavailable - sleeping"
			  sleep 1
			done
		fi

		(cd core && spip install \
			--db-server ${SPIP_DB_SERVER} \
			--db-host ${SPIP_DB_HOST} \
			--db-login ${SPIP_DB_LOGIN} \
			--db-pass ${SPIP_DB_PASS} \
			--db-database ${SPIP_DB_NAME} \
			--db-prefix ${SPIP_DB_PREFIX} \
			--admin-nom ${SPIP_ADMIN_NAME} \
			--admin-login ${SPIP_ADMIN_LOGIN} \
			--admin-email ${SPIP_ADMIN_EMAIL} \
			--admin-pass ${SPIP_ADMIN_PASS} \
        )

		# Fix bug can't create admin account for SPIP 3.0 by retry SPIP install
		# Need to fix spip-cli "mysql_query() expects parameter 2 to be resource"
		if [ ${SPIP_VERSION} == '3.0' ]; then
			(cd spip install \
				--db-server ${SPIP_DB_SERVER} \
				--db-host ${SPIP_DB_HOST} \
				--db-login ${SPIP_DB_LOGIN} \
				--db-pass ${SPIP_DB_PASS} \
				--db-database ${SPIP_DB_NAME} \
				--db-prefix ${SPIP_DB_PREFIX} \
				--admin-nom ${SPIP_ADMIN_NAME} \
				--admin-login ${SPIP_ADMIN_LOGIN} \
				--admin-email ${SPIP_ADMIN_EMAIL} \
				--admin-pass ${SPIP_ADMIN_PASS} \
			)	
		fi
	fi

	if [ ${SPIP_VERSION} == '2.1' ]; then
		>&2 echo "Can't auto install SPIP for this version"
	fi
fi

exec "$@"
