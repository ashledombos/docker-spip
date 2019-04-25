FROM httpd:2.4-alpine
# Copy apache vhost file to proxy php requests to php-fpm container
COPY spip.apache.conf /usr/local/apache2/conf/spip.apache.conf

RUN echo "Include /usr/local/apache2/conf/spip.apache.conf" \
    >> /usr/local/apache2/conf/httpd.conf
    
RUN { \
    echo 'until [ -e /var/www/html/core/htaccess.txt ] && [ -e /var/www/html/data/htdir.txt ]; do'; \
    echo '    >&2 echo "htaccess.txt or htdir.txt unavailable - sleeping"'; \
    echo '    sleep 1'; \
    echo 'done'; \
    echo ''; \
    echo 'exec "$@"'; \
    } > /docker-entrypoint.sh
    
VOLUME ["/var/www/html/core/"]
VOLUME ["/var/www/html/data/"]
    
EXPOSE 80

ENTRYPOINT ["sh","/docker-entrypoint.sh"]

CMD ["/usr/local/apache2/bin/httpd","-D","FOREGROUND"]
