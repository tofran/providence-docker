FROM ubuntu:20.04

ARG TZ=Europe/Lisbon
ENV TZ=$TZ
RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone

RUN apt update && \
    apt install -y \
        apache2 \
        curl \
        ffmpeg \
        ghostscript \
        imagemagick \
        libapache2-mod-php7.4 \
        libreoffice \
        mysql-client \
        php-mysql \
        php7.4 \
        php7.4-curl \
        php7.4-gd \
        php7.4-xml \
        php7.4-zip \
        wget \
        zip \
        \
        # GMAGICK
        graphicsmagick \
        libgraphicsmagick1-dev \
        php-pear \
        php7.4-dev \
        \
        && pecl install gmagick-2.0.4RC1 \
        \
    && apt clean

ARG APACHE_RUN_USER=www-data
ARG APACHE_RUN_GROUP=www-data
ENV APACHE_RUN_USER     $APACHE_RUN_USER
ENV APACHE_RUN_GROUP    $APACHE_RUN_GROUP
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2

ARG CA_PROVIDENCE_VERSION=1.7.16
ENV CA_PROVIDENCE_VERSION $CA_PROVIDENCE_VERSION
ENV CA_PROVIDENCE_DIR     /var/www
ENV INIT_DB               true

RUN rm -rf /var/www/html && \
    mkdir -p "$CA_PROVIDENCE_DIR" && \
    curl -SsL "https://github.com/collectiveaccess/providence/archive/$CA_PROVIDENCE_VERSION.tar.gz" \
        | tar -C /tmp -xzf - && \
    mv "/tmp/providence-$CA_PROVIDENCE_VERSION"/* "$CA_PROVIDENCE_DIR" && \
    cp -r "/$CA_PROVIDENCE_DIR/app/conf" "/$CA_PROVIDENCE_DIR/app/conf-default" && \
    \
    sed -i "s@DocumentRoot \/var\/www\/html@DocumentRoot \/var\/www@g" /etc/apache2/sites-available/000-default.conf && \
    sed -i "s@Options Indexes FollowSymLinks@Options@g" /etc/apache2/apache2.conf && \
    chown -R "$APACHE_RUN_USER":"$APACHE_RUN_GROUP" /var/www/

COPY providence-setup.php "$CA_PROVIDENCE_DIR/setup.php"
COPY php.ini /etc/php/7.0/cli/php.ini
COPY php.ini /etc/php/7.4/apache2/php.ini

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "/usr/sbin/apache2", "-DFOREGROUND" ]
