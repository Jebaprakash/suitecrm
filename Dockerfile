FROM dunglas/frankenphp:php8.3

# Install system dependencies for Debian
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libxml2-dev libonig-dev libimap-php libc-client-dev libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql zip gd intl mbstring bcmath soap opcache mysqli exif imap

WORKDIR /app
COPY . .

# Critical permissions for SuiteCRM 8 and Legacy folders
RUN chmod -R 777 cache logs config \
    && mkdir -p public/legacy/cache public/legacy/upload public/legacy/custom \
    && chmod -R 777 public/legacy/cache public/legacy/upload public/legacy/custom

ENV PORT=8080
EXPOSE 8080

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
