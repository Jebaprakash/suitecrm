FROM dunglas/frankenphp:php8.4-alpine

# Install system dependencies and PHP extensions required for SuiteCRM
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

WORKDIR /app

# Copy SuiteCRM source
COPY . .

# Fix permissions as requested
RUN chmod -R 777 cache custom logs upload config

EXPOSE 8080

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
