#!/usr/bin/env bash
set -euo pipefail

: "${MARIADB_DATABASE:=wordpress}"
: "${MARIADB_USER:=wp_user}"
: "${MARIADB_PASSWORD:=}"
: "${MARIADB_ROOT_PASSWORD:=}"

if [[ -z "$MARIADB_PASSWORD" && -f "/run/secrets/db_password" ]]; then
  MARIADB_PASSWORD="$(tr -d '\r\n' </run/secrets/db_password)"
fi
if [[ -z "$MARIADB_ROOT_PASSWORD" && -f "/run/secrets/db_root_password" ]]; then
	MARIADB_ROOT_PASSWORD="$(tr -d '\r\n' </run/secrets/db_root_password)"
fi

if [[ -z "${MARIADB_ROOT_PASSWORD}" || -z "${MARIADB_PASSWORD}" ]]; then
  echo "[mariadb] MARIADB_ROOT_PASSWORD and MARIADB_PASSWORD must be set via env/secrets" >&2
  exit 1
fi

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chmod 775 /var/run/mysqld

# Initialization
if [[ ! -d "/var/lib/mysql/mysql" ]]; then
  echo "[mariadb] Initializing database directory..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db --auth-root-authentication-method=normal >/dev/null
fi

mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
temp_pid=$!

for _ in {1..60}; do
  if mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"$MARIADB_ROOT_PASSWORD" ping >/dev/null 2>&1 \
     || mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot ping >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Apply idempotent bootstrap: create DB/user if missing; set root password
if ! mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"$MARIADB_ROOT_PASSWORD" <<SQL >/dev/null 2>&1
CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD';
FLUSH PRIVILEGES;
SQL
then
  mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot <<SQL
CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD';
FLUSH PRIVILEGES;
SQL
fi

mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"$MARIADB_ROOT_PASSWORD" shutdown \
  || mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot shutdown || true
wait "$temp_pid" 2>/dev/null || true

echo "[mariadb] Starting MariaDB in foreground"
exec "$@"

