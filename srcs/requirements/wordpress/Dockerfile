FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl less unzip \
       php-fpm php-cli php-mysql php-mbstring php-xml php-curl php-zip php-gd \
       mariadb-client \
       libfcgi-bin \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && wp --info --allow-root

RUN set -eux; \
    conf=$(ls /etc/php/*/fpm/pool.d/www.conf); \
    sed -i 's#^listen = .*#listen = 0.0.0.0:9000#' "$conf"; \
    sed -i 's/^;*clear_env = .*/clear_env = no/' "$conf"; \
    grep -q '^ping.path' "$conf" || echo 'ping.path = /ping' >> "$conf"; \
    grep -q '^pm.status_path' "$conf" || echo 'pm.status_path = /status' >> "$conf";

RUN mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]

