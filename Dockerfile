FROM php:8.3.4-apache-bookworm

ENV APACHE_DOCUMENT_ROOT /var/www/html/public
WORKDIR /var/www/html

USER 1000

COPY . /var/www/html

RUN apt-get update
RUN apt-get upgrade

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get install -y \
    default-mysql-client \
    mariadb-client

RUN apt-get install -y libc-client-dev libkrb5-dev

RUN yes | pecl install imap

RUN docker-php-ext-enable imap

RUN apt-get install zip unzip

RUN composer update 

#RUN composer install
#
## Generate a key
#RUN php artisan key:generate
#
## Migrate the database
#RUN php artisan migrate
#
## Link the storage public folder
#RUN php artisan storage:link
#
## (Optional) Create sample content in the database
#RUN php artisan db:seed