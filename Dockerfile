FROM dunglas/frankenphp:php8.2

# Install system dependencies for SuiteCRM 8
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libxml2-dev libonig-dev libc-client-dev libkrb5-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install all critical PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql zip gd intl mbstring bcmath soap opcache mysqli exif imap xml dom ctype iconv

# Set production PHP settings
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -i 's/memory_limit = .*/memory_limit = 1G/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/max_execution_time = .*/max_execution_time = 600/' "$PHP_INI_DIR/php.ini"

WORKDIR /app
COPY . .

# Ensure all writable directories exist and are fully accessible
RUN mkdir -p cache logs config public/legacy/cache public/legacy/upload public/legacy/custom \
    && chmod -R 777 cache logs config public/legacy/cache public/legacy/upload public/legacy/custom

# Create test files to verify container health
RUN echo "<html><body><h1>Server is UP</h1></body></html>" > public/test.html
RUN echo "<?php phpinfo();" > public/health.php

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
