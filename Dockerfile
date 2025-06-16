# Use PHP 8.2 with Apache web server
FROM php:8.2-apache

# Install system packages Laravel needs
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

# Enable Apache rewrite module (Laravel needs this for routing)
RUN a2enmod rewrite

# Set working directory inside the container
WORKDIR /var/www/html

# Copy the whole Laravel project to the container
COPY . /var/www/html

# Set proper permissions for storage and cache folders
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Install Composer (Laravel dependency manager)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Run Composer install
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# ✅ Run these during the Docker build
RUN php artisan key:generate && php artisan migrate --force