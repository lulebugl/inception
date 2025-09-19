#!/usr/bin/env bash
set -euo pipefail

LOGIN="llebugle"
echo "export LOGIN=${LOGIN}" >> ~/.bashrc
DOMAIN="llebugle.42.fr"
echo "export DOMAIN=${DOMAIN}" >> ~/.bashrc
DATA_ROOT="/home/${LOGIN}/data"
echo "export DATA_ROOT=${DATA_ROOT}" >> ~/.bashrc
source ~/.bashrc

echo "[provision] LOGIN=${LOGIN} DOMAIN=${DOMAIN} DATA_ROOT=${DATA_ROOT}"

ensure_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl gnupg lsb-release openssl make vim git
  fi
}

install_docker() {
  if docker info >/dev/null 2>&1; then
    echo "[provision] Docker (daemon) already running."
    return
  fi

  if command -v apt-get >/dev/null 2>&1; then
    sudo install -m 0755 -d /etc/apt/keyrings || true
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
      curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg
    fi
    codename=$( . /etc/os-release; echo "$VERSION_CODENAME" )
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") ${codename} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  target_user="${SUDO_USER:-$USER}"
  if getent group docker >/dev/null 2>&1; then
    sudo usermod -aG docker "$target_user" 2>/dev/null || true
  fi
}

create_data_dirs() {
  echo "[provision] Creating data directories under ${DATA_ROOT}"
  sudo mkdir -p "${DATA_ROOT}/mariadb" "${DATA_ROOT}/wordpress" "${DATA_ROOT}/certs"
  sudo chown -R "${SUDO_USER:-$USER}":"${SUDO_USER:-$USER}" "$DATA_ROOT"
}

ensure_dev_cert() {
  local crt="${DATA_ROOT}/certs/${DOMAIN}.crt"
  local key="${DATA_ROOT}/certs/${DOMAIN}.key"
  if [[ -f "$crt" && -f "$key" ]]; then
    echo "[provision] TLS cert already present: ${crt}"
    return
  fi
  echo "[provision] Generating self-signed TLS cert for ${DOMAIN}"
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$key" \
    -out "$crt" \
    -subj "/CN=${DOMAIN}" >/dev/null 2>&1
}

ensure_packages
install_docker
create_data_dirs
ensure_dev_cert

echo "[provision] Done."

