FROM dunglas/frankenphp:php8.2

# Install system dependencies for SuiteCRM 8 on Debian
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libc-client-dev \
    libkrb5-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
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

# Production-ready PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Set PHP configurations for SuiteCRM
RUN sed -i 's/memory_limit = .*/memory_limit = 512M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/post_max_size = .*/post_max_size = 100M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/max_execution_time = .*/max_execution_time = 300/' "$PHP_INI_DIR/php.ini"

WORKDIR /app

# Copy application files
COPY . .

# Critical permissions for SuiteCRM 8 and Legacy folders
RUN chmod -R 777 cache logs config public/legacy/cache public/legacy/upload public/legacy/custom

ENV PORT=8080
EXPOSE 8080

CMD ["frankenphp", "run", "--config", "/app/Caddyfile"]
