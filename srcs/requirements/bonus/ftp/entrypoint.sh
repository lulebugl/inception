#!/bin/sh
set -eu

FTP_USER="${FTP_USER:-www-data}"
FTP_PASS="$(tr -d '\r\n' </run/secrets/ftp_password || true)"
PASV_ADDRESS="${PASV_ADDRESS:-127.0.0.1}"
PASV_MIN_PORT="${PASV_MIN_PORT:-21100}"
PASV_MAX_PORT="${PASV_MAX_PORT:-21110}"


if ! id -u "${FTP_USER}" >/dev/null 2>&1; then
  # Create group and user with UID/GID 33 (www-data standard) if not present
  addgroup --gid 33 www-data || true
  adduser --disabled-password --gecos "" --uid 33 --gid 33 "${FTP_USER}" || true
fi

current_home="$(getent passwd "$FTP_USER" | cut -d: -f6 || true)"
[ "$current_home" = "/var/www/html" ] || usermod -d /var/www/html "$FTP_USER" 2>/dev/null || true

current_shell="$(getent passwd "$FTP_USER" | cut -d: -f7 || true)"
[ "$current_shell" = "/bin/sh" ] || usermod -s /bin/sh "$FTP_USER" 2>/dev/null || true
grep -q '^/bin/sh$' /etc/shells || echo /bin/sh >> /etc/shells

mkdir -p /var/run/vsftpd/empty
chown root:root /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

install -d -m 775 -o www-data -g www-data \
  /var/www/html/wp-content/{uploads,upgrade,plugins,themes,backups,temp,logs}

find /var/www/html/wp-content -type d -exec chmod 2775 {} +
find /var/www/html/wp-content -type f -exec chmod 664 {} +

if [ -n "${FTP_PASS:-}" ]; then
  echo "${FTP_USER}:${FTP_PASS}" | chpasswd
fi

echo "${FTP_USER}" > /etc/vsftpd.userlist

sed -i '/^pasv_\(min_port\|max_port\|address\|addr_resolve\)=/d' /etc/vsftpd.conf
{
  echo "pasv_enable=YES"
  echo "pasv_min_port=${PASV_MIN_PORT:-21100}"
  echo "pasv_max_port=${PASV_MAX_PORT:-21110}"
  echo "pasv_address=${PASV_ADDRESS:-127.0.0.1}"
  echo "pasv_addr_resolve=YES"
} >> /etc/vsftpd.conf

install -d -m 755 -o root -g root /var/log
: > /var/log/xferlog
chmod 644 /var/log/xferlog
# stream to docker logs
tail -F /var/log/xferlog &

exec /usr/sbin/vsftpd -obackground=NO /etc/vsftpd.conf
