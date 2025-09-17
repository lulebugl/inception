#!/usr/bin/env bash
set -euo pipefail

: "${MARIADB_DATABASE:=wordpress}"
: "${MARIADB_USER:=wp_user}"
: "${WP_URL:=https://login.42.fr}"
: "${WP_TITLE:=Inception}"
: "${WP_ADMIN_USER:=owner}"
: "${WP_ADMIN_EMAIL:=owner@example.com}"

read_secret() { tr -d '\r\n' < "$1" 2>/dev/null || true; }
DB_PASS="$(read_secret /run/secrets/db_password)"

if [[ -z "$DB_PASS" ]]; then
  echo "[wordpress] db password missing in /run/secrets/db_password" >&2
  exit 1
fi

for _ in {1..60}; do
  if mysqladmin -hmariadb -u"$MARIADB_USER" -p"$DB_PASS" ping >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Download and configure WordPress if missing
if [[ ! -f wp-config.php ]]; then
  echo "[wordpress] Bootstrapping WordPress core..."
  wp core download --allow-root
  wp config create --allow-root \
    --dbname="$MARIADB_DATABASE" \
    --dbuser="$MARIADB_USER" \
    --dbpass="$DB_PASS" \
    --dbhost="mariadb:3306"
fi

# Install site if not installed
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  echo "[wordpress] Installing site..."
  WP_ADMIN_PASS=$(read_secret /run/secrets/wp_admin_password)
  if [[ -z "$WP_ADMIN_PASS" ]]; then
    WP_ADMIN_PASS=$(openssl rand -hex 16)
    echo "[wordpress] Generated admin password (ephemeral)"
  fi
  wp core install --allow-root \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASS" \
    --admin_email="$WP_ADMIN_EMAIL"
  # Create a regular user as required by subject (non-admin)
  if ! wp user get author --field=ID --allow-root >/dev/null 2>&1; then
    wp user create author author@example.com --role=author --user_pass="$(openssl rand -hex 12)" --allow-root
  fi
fi

# ensure PID dir exists and is writable
install -d -m 755 -o www-data -g www-data /run/php
PHP_FPM_BIN="$(command -v php-fpm || ls /usr/sbin/php-fpm* 2>/dev/null | head -n1)"
echo "[wordpress] Starting php-fpm"
exec "$PHP_FPM_BIN" -F

