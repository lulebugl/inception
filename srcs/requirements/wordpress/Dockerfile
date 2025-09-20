FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 9000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl gnupg lsb-release less unzip mariadb-client libfcgi-bin \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/sury.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/sury.gpg] https://packages.sury.org/php $(lsb_release -sc) main" \
       > /etc/apt/sources.list.d/sury-php.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       php8.2-fpm php8.2-cli php8.2-mysql php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip php8.2-gd \
       php8.2-redis \
    && rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/z-www.conf

RUN mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www

COPY conf/wp-config.php /usr/src/wp-config.php
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]

