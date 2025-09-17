#!/usr/bin/env bash
set -euo pipefail

export DOMAIN="${DOMAIN:-${DOMAIN_NAME:-}}"

TEMPLATE=/etc/nginx/templates/nginx.conf.template
TARGET=/etc/nginx/nginx.conf
if [[ -f "$TEMPLATE" ]]; then
  envsubst '$DOMAIN' < "$TEMPLATE" > "$TARGET"
else
  echo "[nginx] Missing template: $TEMPLATE" >&2
  exit 1
fi

if [[ ! -s "$TARGET" ]]; then
  echo "[nginx] Generated config is empty: $TARGET" >&2
  exit 1
fi

if [[ -z "$DOMAIN" || ! -f "/etc/nginx/certs/${DOMAIN}.crt" || ! -f "/etc/nginx/certs/${DOMAIN}.key" ]]; then
  echo "[nginx] Missing or invalid certs for domain '$DOMAIN' in /etc/nginx/certs" >&2
fi

exec "$@"

