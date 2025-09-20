#!/usr/bin/env bash
set -euo pipefail

# Update /etc/hosts on macOS to map DOMAIN -> VM_IP
# Usage:
#   DOMAIN=login.42.fr VM_IP=192.168.56.10 bash scripts/update-hosts.sh

DOMAIN="llebugle.42.fr"
DOZZLE_DOMAIN="dozzle.${DOMAIN}"
VM_IP="${VM_IP:-}"

if [[ -z "$DOMAIN" || -z "$VM_IP" ]]; then
  echo "Usage: DOMAIN=login.42.fr VM_IP=192.168.56.10 bash $0" >&2
  exit 1
fi

tmp=$(mktemp)
grep -vE "\s${DOMAIN}$" /etc/hosts > "$tmp" || true
echo "${VM_IP} ${DOMAIN}" >> "$tmp"
echo "${VM_IP} ${DOZZLE_DOMAIN}" >> "$tmp"
sudo mv "$tmp" /etc/hosts
echo "[update-hosts] Mapped ${DOMAIN} -> ${VM_IP}"

