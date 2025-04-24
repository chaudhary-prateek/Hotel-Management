#
## Use official PHP image with Apache
#FROM php:8.2-apache
#
## Enable Apache mod_rewrite
#RUN a2enmod rewrite
#
## Set working directory
#WORKDIR /var/www/html
#
## Install system dependencies
#RUN apt-get update && apt-get install -y \
#    git \
#    unzip \
#    zip \
#    libzip-dev \
#    libpng-dev \
#    libonig-dev \
#    libxml2-dev \
#    curl \
#    && docker-php-ext-install pdo pdo_mysql zip
#
## Install Composer
#COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
#
## Copy Laravel files to container
#COPY . /var/www/html
#
## Set correct permissions
#RUN chown -R www-data:www-data /var/www/html \
#    && chmod -R 755 /var/www/html
#
## Copy Apache virtual host config
#COPY ./docker/vhost.conf /etc/apache2/sites-available/000-default.conf
#
## Expose port 80
#EXPOSE 80
#
## Start Apache in the foreground
#CMD ["apache2-foreground"]
#

# Use official PHP image with Apache or CLI
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    libzip-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Copy existing application directory
COPY . .

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"]
