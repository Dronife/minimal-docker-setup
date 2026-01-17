FROM php:8.4-fpm

WORKDIR /var/www

# ======= CORE SYSTEM UTILITIES =======
# git/unzip: for composer
# libzip-dev: for zip extension
# libonig-dev: for mbstring extension
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev libonig-dev \
    supervisor \
# ======= PDF & HEADLESS BROWSER (LIKELY DELETE THIS) =======
#    chromium chromium-sandbox fonts-liberation \
#    libasound2 libatk-bridge2.0-0 libdrm2 libgtk-3-0 \
#    libnspr4 libnss3 libx11-xcb1 libxcomposite1 \
#    libxdamage1 libxrandr2 xdg-utils libxss1 \
#    ca-certificates gnupg \
#    pdftk ghostscript \
# ===========================================================
# ======= FRONTEND BUILD TOOLS (OPTIONAL) =======
# Only keep if you run 'npm run dev' INSIDE this container
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
# ===============================================
# ======= PHP EXTENSIONS =======
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    bcmath \
    zip \
# ==============================
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set permissions (Standard)
RUN chown -R www-data:www-data /var/www

# ======= CHROMIUM ENV (DELETE IF REMOVING CHROMIUM) =======
# ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# ==========================================================

# User setup
RUN groupadd -g 1002 appgroup && \
    useradd -u 1002 -g appgroup -m appuser

USER appuser:appgroup

EXPOSE 9000
CMD ["php-fpm"]
