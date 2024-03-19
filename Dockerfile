FROM php:8.3.4-apache-bookworm

# Install required PHP extensions
RUN docker-php-ext-install \
    openssl \
    pdo \
    mbstring \
    tokenizer \
    xml \
    ctype \
    json \
    bcmath \
    imap

# Install MySQL/MariaDB client
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    mariadb-client

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Git
RUN apt-get install -y git

