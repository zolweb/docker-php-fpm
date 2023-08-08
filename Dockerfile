FROM composer:2.5.8 AS composer

FROM php:8.2.7-fpm

ARG APCU_VERSION=5.1.22
ENV COMPOSER_ALLOW_SUPERUSER 1
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get --allow-releaseinfo-change update -qq && apt-get install -qqy \
    sudo \
    wget \
    git \
    apt-utils \
    acl \
    openssl \
    nano \
    htop \
    unzip \
    tzdata \
    netcat-traditional \
    iproute2 \
    cron \
    libicu-dev \
    libzip-dev \
    libonig-dev \
    libmcrypt-dev \
    mariadb-client \
    postgresql-client \
    libfreetype6-dev libjpeg-dev \
    apt-transport-https lsb-release ca-certificates \
    software-properties-common \
    libbz2-dev \
    libpq-dev \
    libwebp-dev \
    && echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata \
    && echo 'alias ll="ls -lah --color=auto"' >> /etc/bash.bashrc \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install \
       iconv \
       intl \
       pdo \
       pdo_mysql \
       pdo_pgsql \
       pgsql \
       mbstring \
       opcache \
       zip \
       gd \
       exif \
       bz2 \
    && pecl install xdebug apcu-${APCU_VERSION} \
    && docker-php-ext-enable xdebug apcu \
    && usermod -u 1000 www-data \
    && groupmod -g 1000 www-data \
    && find / -user 33 -exec chown -h 1000 {} \; || true \
    && find / -group 33 -exec chgrp -h 1000 {} \; || true \
    && usermod -g 1000 www-data

# Custom logrotate configuration for symfony
ADD logrotate/symfony /etc/logrotate.d/symfony
ADD logrotate/php /etc/logrotate.d/php
ADD logrotate/cron /etc/periodic/daily/logrotate-cron

# Custom PHP configuration
COPY php/php.ini /usr/local/etc/php/php.ini

COPY script/start.sh /opt/scripts/start.sh
COPY script/entry.sh /opt/scripts/entry.sh

# Make sure every user can start the container
RUN chown -R 1000:1000 /opt/scripts \
    && chmod 0777 /opt/scripts/start.sh /opt/scripts/entry.sh \
    && chmod +x /etc/periodic/daily/logrotate-cron

WORKDIR /var/www/html

ENTRYPOINT ["/opt/scripts/entry.sh"]
CMD ["/opt/scripts/start.sh"]
