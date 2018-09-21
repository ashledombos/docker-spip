FROM httpd:2.4.34-alpine
RUN apk update; \
    apk upgrade;
# Copy apache vhost file to proxy php requests to php-fpm container
COPY spip.apache.conf /usr/local/apache2/conf/spip.apache.conf
RUN echo "Include /usr/local/apache2/conf/spip.apache.conf" \
    >> /usr/local/apache2/conf/httpd.conf
