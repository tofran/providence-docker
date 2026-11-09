FROM composer:2 AS composer

FROM php:8.5-apache-trixie

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TZ=Etc/UTC
ENV TZ=$TZ

# Unpinned apt packages: versions track the Debian release of the base image.
# hadolint ignore=DL3008
RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        curl \
        dcraw \
        ffmpeg \
        ghostscript \
        imagemagick \
        libfreetype-dev \
        libgmp-dev \
        libicu-dev \
        libimage-exiftool-perl \
        libjpeg62-turbo-dev \
        libmagickwand-dev \
        libonig-dev \
        libpng-dev \
        libreoffice \
        libwebp-dev \
        libzip-dev \
        mariadb-client \
        mediainfo \
        poppler-utils \
        unzip \
        wget \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j"$(nproc)" bcmath exif gd gmp intl mbstring mysqli pdo_mysql posix zip && \
    pecl install imagick-3.8.1 && \
    docker-php-ext-enable imagick && \
    rm -rf /tmp/pear

COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

ARG APACHE_RUN_USER=www-data
ARG APACHE_RUN_GROUP=www-data

ENV APACHE_RUN_USER=$APACHE_RUN_USER \
    APACHE_RUN_GROUP=$APACHE_RUN_GROUP \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    APACHE_RUN_DIR=/var/run/apache2

ARG CA_PROVIDENCE_VERSION=2.0.12

ENV CA_PROVIDENCE_VERSION=$CA_PROVIDENCE_VERSION \
    CA_PROVIDENCE_DIR=/var/www \
    INIT_DB=true

# Release archives do not ship vendor/, so dependencies are installed from composer.lock.
RUN rm -rf /var/www/html && \
    curl -SsL "https://github.com/collectiveaccess/providence/archive/$CA_PROVIDENCE_VERSION.tar.gz" \
        | tar -C /tmp -xzf - && \
    mkdir -p "$CA_PROVIDENCE_DIR" && \
    mv "/tmp/providence-$CA_PROVIDENCE_VERSION"/* "$CA_PROVIDENCE_DIR" && \
    rm -rf "/tmp/providence-$CA_PROVIDENCE_VERSION" && \
    COMPOSER_ALLOW_SUPERUSER=1 composer install \
        --working-dir="$CA_PROVIDENCE_DIR" \
        --no-dev \
        --no-interaction \
        --no-progress \
        --optimize-autoloader && \
    rm -rf /root/.composer/cache && \
    rm -rf License.txt README.md SECURITY.md THANKS.txt Vagrantfile Vagrantfile.debian-stretch64 Vagrantfile.focal \
        Warranty.txt tests assets/universalviewer/src && \
    cp -r "$CA_PROVIDENCE_DIR/app/conf" "$CA_PROVIDENCE_DIR/app/conf-default" && \
    mkdir -p "$CA_PROVIDENCE_DIR/media/collectiveaccess" && \
    \
    sed -i "s@DocumentRoot \/var\/www\/html@DocumentRoot \/var\/www@g" /etc/apache2/sites-available/000-default.conf && \
    sed -i "s@Options Indexes FollowSymLinks@Options@g" /etc/apache2/apache2.conf && \
    chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" /var/www/

# Workaround: since 2.0.12 caGetHTMLPurifier() builds a new HTMLPurifier_HTML5Config on every
# call, leaving ~0.8 MB of cyclic garbage each time. The web installer exhausts its 512M limit
# before PHP's cycle collector runs. Reuse one instance per request (its config is static).
# The grep fails the build if the function changes upstream, so the patch gets re-checked.
RUN perl -0pi -e 's/(function caGetHTMLPurifier\(\?array \$options=null\) : HTMLPurifier \{\n)/$1\t\tstatic \$purifier = null;\n\t\tif (\$purifier) { return \$purifier; }\n/; s/return new HTMLPurifier\(\$config\);/return \$purifier = new HTMLPurifier(\$config);/' \
        "$CA_PROVIDENCE_DIR/app/helpers/utilityHelpers.php" && \
    grep -q 'return $purifier = new HTMLPurifier($config);' "$CA_PROVIDENCE_DIR/app/helpers/utilityHelpers.php" && \
    grep -q 'if ($purifier) { return $purifier; }' "$CA_PROVIDENCE_DIR/app/helpers/utilityHelpers.php" && \
    \
    # Workaround: 2.0.12 replaced `use CLIUtilsMigration;` with `use CLIUtilsSitemap;` in caUtils,
    # dropping the update-from-1-7 and update-database-schema commands. Restore the trait.
    if ! grep -q 'use CLIUtilsMigration;' "$CA_PROVIDENCE_DIR/app/lib/Utils/CLIUtils.php"; then \
        perl -pi -e 's/^(\t)use CLIUtilsSitemap;$/$1use CLIUtilsMigration;\n$1use CLIUtilsSitemap;/' \
            "$CA_PROVIDENCE_DIR/app/lib/Utils/CLIUtils.php" && \
        grep -q 'use CLIUtilsMigration;' "$CA_PROVIDENCE_DIR/app/lib/Utils/CLIUtils.php"; \
    fi

COPY ./providence-setup.php "$CA_PROVIDENCE_DIR/setup.php"
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "/usr/sbin/apache2", "-DFOREGROUND" ]
