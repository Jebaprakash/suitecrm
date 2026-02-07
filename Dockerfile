FROM dunglas/frankenphp:php8.2-alpine

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    libxml2-dev \
    oniguruma-dev \
    imap-dev \
    bash

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    pdo_mysql \
    zip \
    gd \
    intl \
    mbstring \
    bcmath \
    soap \
    opcache \
    mysqli \
    exif \
    imap

# Use production PHP settings
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Set PHP configurations for SuiteCRM
RUN sed -i 's/memory_limit = .*/memory_limit = 512M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/post_max_size = .*/post_max_size = 100M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/max_execution_time = .*/max_execution_time = 300/' "$PHP_INI_DIR/php.ini"

WORKDIR /app

# Copy SuiteCRM source
COPY . /app

# Fix permissions for SuiteCRM 8 and Legacy
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app \
    && find /app/cache -type d -exec chmod 775 {} + \
    && find /app/public/legacy -type d -name "cache" -exec chmod 775 {} + \
    && find /app/public/legacy -type d -name "upload" -exec chmod 775 {} + \
    && find /app/public/legacy -type d -name "modules" -exec chmod 775 {} +

ENV PORT=8080

EXPOSE 8080

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
