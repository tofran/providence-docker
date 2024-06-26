FROM php:7.4-apache-bullseye

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TZ=Etc/UTC
ENV TZ=$TZ

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        curl \
        ffmpeg \
        ghostscript \
        imagemagick \
        libmagickwand-dev \
        libreoffice \
        libzip-dev \
        mariadb-client \
        wget \
        zip \
        libonig-dev \
        libgmp-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    docker-php-ext-install gd gmp intl mbstring mysqli pdo_mysql posix xmlrpc zip && \
    pecl install imagick-3.7.0 && \
    docker-php-ext-enable gd gmp intl mbstring mysqli pdo_mysql posix xmlrpc zip imagick

WORKDIR /var/www

ARG APACHE_RUN_USER=www-data
ARG APACHE_RUN_GROUP=www-data

ENV APACHE_RUN_USER     $APACHE_RUN_USER
ENV APACHE_RUN_GROUP    $APACHE_RUN_GROUP
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2

ARG CA_PROVIDENCE_VERSION=1.7.17

ENV CA_PROVIDENCE_VERSION $CA_PROVIDENCE_VERSION
ENV CA_PROVIDENCE_DIR     /var/www
ENV INIT_DB               true

RUN rm -rf /var/www/html && \
    curl -SsL "https://github.com/collectiveaccess/providence/archive/$CA_PROVIDENCE_VERSION.tar.gz" \
        | tar -C /tmp -xzf - && \
    mkdir -p "$CA_PROVIDENCE_DIR" && \
    mv "/tmp/providence-$CA_PROVIDENCE_VERSION"/* "$CA_PROVIDENCE_DIR" && \
    rm -rf License.txt README.md SECURITY.md THANKS.txt Vagrantfile Vagrantfile.debian-stretch64 Warranty.txt \
        tests assets/universalviewer/src && \
    cp -r "/$CA_PROVIDENCE_DIR/app/conf" "/$CA_PROVIDENCE_DIR/app/conf-default" && \
    mkdir -p "$CA_PROVIDENCE_DIR/media/collectiveaccess" && \
    \
    sed -i "s@DocumentRoot \/var\/www\/html@DocumentRoot \/var\/www@g" /etc/apache2/sites-available/000-default.conf && \
    sed -i "s@Options Indexes FollowSymLinks@Options@g" /etc/apache2/apache2.conf && \
    chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" /var/www/

COPY ./providence-setup.php "$CA_PROVIDENCE_DIR/setup.php"
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "/usr/sbin/apache2", "-DFOREGROUND" ]
