FROM php:8.2.17-apache-bookworm

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    mariadb-client \
    libc-client-dev \
    libkrb5-dev \
    libzip-dev \
    zip \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install pdo_mysql imap

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Avoid running Composer as root/super user
ENV COMPOSER_ALLOW_SUPERUSER=1

# Copy Laravel application code
COPY . .

# Use composer install instead of update to install dependencies
# from the composer.lock file, and ignore platform reqs for PHP and ext-imap temporarily
RUN composer update --no-interaction --prefer-dist --optimize-autoloader

# Download and configure PHPMyAdmin
RUN apt-get update && apt-get install -y ca-certificates unzip --no-install-recommends \
    && wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -O phpmyadmin.zip \
    && unzip phpmyadmin.zip \
    && rm phpmyadmin.zip \
    && mv phpMyAdmin-5.2.1-all-languages /var/www/phpmyadmin \
    && cp /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure Apache to serve the Laravel app
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy and set the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Optional: Run as non-root user for security
RUN usermod -u 1000 www-data && chown -R www-data:www-data /var/www
USER www-data

CMD ["apache2-foreground"]