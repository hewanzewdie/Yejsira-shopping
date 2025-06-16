# Stage 1: Base image with PHP and Apache
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    curl \
    zip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip mbstring

# Enable Apache rewrite module (needed by Laravel routes)
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Copy the Laravel project files
COPY . .

# Ensure storage and cache folders are writable
RUN chown -R www-data:www-data storage bootstrap/cache

# Install Composer manually
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Copy .env.example to .env (for build-time artisan commands)
RUN cp .env.example .env

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Generate app key and run database migrations
RUN php artisan key:generate && php artisan migrate --force
