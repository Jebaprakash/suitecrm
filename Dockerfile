FROM dunglas/frankenphp:php8.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-install pdo_mysql zip gd

# Set working directory
WORKDIR /app

# Copy SuiteCRM source
COPY . /app

# Fix permissions
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app

# Railway uses port 8080
EXPOSE 8080

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
