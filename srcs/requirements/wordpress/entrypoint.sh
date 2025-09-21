#!/usr/bin/env bash
set -euo pipefail

read_secret() { tr -d '\r\n' < "$1" 2>/dev/null || true; }

DB_PASS="$(read_secret /run/secrets/db_password)"
if [[ -z "$DB_PASS" ]]; then
  echo "[wordpress] db password missing in /run/secrets/db_password" >&2
  exit 1
fi

if ! command -v wp >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
  chmod +x /usr/local/bin/wp
fi


if [[ ! -e wp-includes/version.php ]]; then
  echo "[wordpress] Downloading WordPress..."
  wp core download --allow-root
fi

cp /usr/src/wp-config.php wp-config.php
sed -i "s/database_name_here/${MARIADB_DATABASE}/" wp-config.php
sed -i "s/username_here/${MARIADB_USER}/" wp-config.php
sed -i "s/password_here/${DB_PASS}/" wp-config.php

echo "[wordpress] Waiting for database..."
for _ in {1..60}; do
  if mariadb -hmariadb -u"$MARIADB_USER" -p"$DB_PASS" -e "SELECT 1" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  echo "[wordpress] Installing site..."
  if [[ "${WP_ADMIN_USER}" =~ [Aa]dmin|[Aa]dministrator ]]; then
        echo "Error: Administrator username cannot contain 'admin', 'Admin', or 'administrator' ..."
        exit 1
  fi

  WP_ADMIN_PASS=$(read_secret /run/secrets/wp_admin_password)
  if [[ -z "$WP_ADMIN_PASS" ]]; then
    echo "[wordpress] admin password missing in /run/secrets/wp_admin_password" >&2
	exit 1
  fi

  wp core install --allow-root \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email

  # Create a regular user if requested, else create a default author
  : "${WP_USER:=author}"
  : "${WP_USER_EMAIL:=author@example.com}"
  if ! wp user get "$WP_USER" --field=ID --allow-root >/dev/null 2>&1; then
  	WP_USER_PASSWORD=$(read_secret /run/secrets/wp_user_password)
  	if [[ -z "$WP_USER_PASSWORD" ]]; then
   		echo "[wordpress] user password missing in /run/secrets/wp_user_password" >&2
   		exit 1
   	fi
    wp user create "$WP_USER" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role=author --allow-root
  fi
fi

: "${WP_THEME:=kubio}"
# : "${WP_THEME:=inspiro}"

if ! wp theme is-installed $WP_THEME --allow-root >/dev/null 2>&1; then
  echo "[wordpress] Installing theme..."
  wp theme install $WP_THEME --activate --allow-root
else
  echo "[wordpress] Activating theme..."
  wp theme activate $WP_THEME --allow-root
fi

if ! wp plugin is-installed redis-cache --allow-root >/dev/null 2>&1; then
  wp plugin install redis-cache --activate --allow-root
  wp redis enable --force --allow-root
fi

install -d -m 755 -o www-data -g www-data /run/php /var/www/html \
 /var/www/html/wp-content/{uploads,upgrade,plugins,themes,backups,temp,logs}
chown -R www-data:www-data /var/www/html/wp-content
find /var/www/html/wp-content -type d -exec chmod 2775 {} +

echo "[wordpress] Starting php-fpm8.2"
exec "$@"

