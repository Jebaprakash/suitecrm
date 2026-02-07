FROM dunglas/frankenphp:php8.2

# Install system dependencies including Composer
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libxml2-dev libonig-dev libc-client-dev libkrb5-dev libssl-dev \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql zip gd intl mbstring bcmath soap opcache mysqli exif imap xml dom ctype iconv

# Set PHP prod config
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -i 's/memory_limit = .*/memory_limit = 512M/' "$PHP_INI_DIR/php.ini"

WORKDIR /app
COPY . .

# Set environment variables for Symfony
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Ensure autoloader is optimized for production
RUN composer dump-autoload --optimize --no-dev --classmap-authoritative

# Permissions - SuiteCRM 8 needs these to be writable
RUN mkdir -p cache logs config public/legacy/cache public/legacy/upload public/legacy/custom \
    && chmod -R 777 cache logs config public/legacy/cache public/legacy/upload public/legacy/custom

# Ensure health check files are present
RUN echo "Server is UP" > public/test.txt

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
