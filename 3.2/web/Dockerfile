FROM httpd:2.4-alpine
LABEL maintainer "Raphaël Jadot"
# Copy apache vhost file to proxy php requests to php-fpm container
COPY spip.apache.conf /usr/local/apache2/conf/spip.apache.conf

RUN echo "Include /usr/local/apache2/conf/spip.apache.conf" \
    >> /usr/local/apache2/conf/httpd.conf

VOLUME ["/var/www/html/core/"]
VOLUME ["/var/www/html/data/"]

#RUN { \
#    if [ ! -e /var/www/html/data/htdir.txt ]; then \
#      echo "#Put your Apache Directory or Location rules here" > /var/www/html/data/htdir.txt; \
#    fi \
#    }
    
RUN { \
    echo 'until [ -e /var/www/html/data/htaccess.txt ] && [ -e /var/www/html/data/htdir.txt ]; do'; \
    echo '    >&2 echo "htaccess.txt or htdir.txt unavailable - sleeping"'; \
    echo '    sleep 1'; \
    echo 'done'; \
    echo ''; \
    echo 'exec "$@"'; \
    } > /docker-entrypoint.sh
    
EXPOSE 80

ENTRYPOINT ["sh","/docker-entrypoint.sh"]

CMD ["/usr/local/apache2/bin/httpd","-D","FOREGROUND"]
