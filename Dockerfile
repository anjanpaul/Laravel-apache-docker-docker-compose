FROM php:7.4-apache
MAINTAINER anjan@sharetrip.net

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions pdo_mysql zip


# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    curl libicu-dev libsodium-dev libsodium23 libzip-dev

RUN docker-php-ext-install gd pdo_mysql opcache session pdo intl sockets sodium zip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./server-config/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite &&\
    service apache2 restart

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /var/www/html

# a little hack for production
# COPY  composer.json ./composer.json

COPY . /var/www/html
RUN composer update 

# for production
# RUN composer install


RUN chmod -R 777 storage/*
# RUN chmod -R 777 bootstrap/cache


EXPOSE 80
