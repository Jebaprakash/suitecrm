FROM dunglas/frankenphp:php8.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libxml2-dev libonig-dev libc-client-dev libkrb5-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql zip gd intl mbstring bcmath soap opcache mysqli exif imap xml dom ctype iconv

# Set PHP prod config
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

WORKDIR /app
COPY . .

# Permissions
RUN mkdir -p cache logs config public/legacy/cache public/legacy/upload public/legacy/custom \
    && chmod -R 777 cache logs config public/legacy/cache public/legacy/upload public/legacy/custom

# IMPORTANT: Remove hardcoded EXPOSE and ENV PORT to let Railway handle it
# Railway will automatically detect the port from the Caddyfile or provide it via $PORT

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
