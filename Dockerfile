FROM dunglas/frankenphp:php8.4-alpine

# Install all necessary extensions for SuiteCRM 8
RUN apk add --no-cache \
    git unzip libzip-dev libpng-dev libjpeg-turbo-dev \
    freetype-dev icu-dev libxml2-dev oniguruma-dev imap-dev bash

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql zip gd intl mbstring bcmath soap opcache mysqli exif imap

WORKDIR /app
COPY . .

# Set permissions for BOTH SuiteCRM 8 and the Legacy paths
RUN chmod -R 777 cache logs config \
    && mkdir -p public/legacy/cache public/legacy/upload public/legacy/custom \
    && chmod -R 777 public/legacy/cache public/legacy/upload public/legacy/custom

ENV PORT=8080
EXPOSE 8080

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
