# Build stage
# Installs dependencies including node and composer, copies necessary config files from the local context and some changes to the database migrations and cleans the build folder
FROM php:8.1-apache as builder
SHELL ["/bin/bash", "--login", "-c"]
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/Paris" MIX_APP_PATH="ThesauRex/"
RUN apt-get update && apt-get install -y curl apt-transport-https &&\
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash &&\
    . ~/.nvm/nvm.sh &&\
    nvm install 16 && nvm use 16 &&\
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&\
    apt-get --assume-yes install git libpq-dev libxml2-dev libcurl4-openssl-dev libzip-dev zip libz-dev libmemcached-dev postgresql &&\
    pecl install memcached &&\
    docker-php-ext-install pgsql xml curl zip pdo pdo_pgsql &&\
    docker-php-ext-enable memcached &&\
    git clone https://github.com/DH-Center-Tuebingen/ThesauRex &&\
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /var/www/html/ThesauRex/
RUN mkdir -p /lumen
COPY .env .env 
COPY .env /var/www/html/ThesauRex/lumen/  
COPY /configs/app/ /var/www/html/ThesauRex/app/ 
COPY /configs/php/ /var/www/html/ThesauRex/database/migrations/ 
RUN npm install &&\
    composer install --no-dev &&\
    npm run prod &&\
    rm -rf /var/www/html/ThesauRex/node_modules 

# Production stage
# Installs dependencies and configures Apache
FROM php:8.1-alpine as production
LABEL maintainer="bcdh@uni-bonn.de"
ARG USER="dunkleosteus" UID=1000
RUN apk add --no-cache autoconf g++ make linux-headers apache2 apache2-proxy git libpq-dev libxml2-dev curl-dev libzip-dev zip zlib-dev libmemcached-dev &&\
    pecl install memcached xdebug &&\
    docker-php-ext-install pgsql xml curl zip pdo pdo_pgsql &&\
    docker-php-ext-enable memcached xdebug &&\
    git config --global --add safe.directory '*' &&\
    rm -rf /tmp/pear && apk del autoconf g++ make
COPY --from=builder --chown=www-data:www-data /var/www/html/ThesauRex/ /var/www/html/ThesauRex/
ENV APACHE_LOG_DIR /var/log/apache2
COPY /configs/apache/httpd-vhosts.conf /etc/apache2/conf.d/app.conf
WORKDIR /var/www/html/ThesauRex/
RUN echo "Include /etc/apache2/conf.d/app.conf" \
    >> /etc/apache2/httpd.conf &&\
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
EXPOSE 80 8000