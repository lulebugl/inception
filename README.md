## Inception

A Docker-Compose based mini-infrastructure with three services: NGINX (TLS-only), WordPress (php-fpm only), and MariaDB (DB only). All services run in separate containers built from your own Dockerfiles, using Alpine or Debian (penultimate stable versions). No ready-made images (besides base OS) and no hacky infinite-loop entrypoints.

Replace `login` with your 42 login everywhere (e.g., volumes path `/home/login/data`, domain `login.42.fr`).

## Global TODO
- [ ] Choose base OS for all images: **Alpine** or **Debian** (penultimate stable only)
- [ ] Create a dedicated Docker network in `docker-compose.yml` (no host network, no links)
- [ ] Ensure each service image name matches its service name
- [ ] Avoid the `latest` tag everywhere
- [ ] Set `restart` policy for all containers (e.g., `always` or `unless-stopped`)
- [ ] Add meaningful `HEALTHCHECK`s where practical
- [ ] Use environment variables and `.env` file; keep passwords out of Dockerfiles
- [ ] Use Docker secrets (or Compose secrets) for confidential values
- [ ] Ensure no infinite loops or `tail -f`, `sleep`, `bash`-as-PID1, or `while true`
- [ ] Verify proper PID 1 handling in each container (use native daemons or correct foreground mode)

### Service: NGINX (sole entry point on 443 with TLSv1.2/1.3)
- [ ] Create `srcs/requirements/nginx/Dockerfile` (Alpine/Debian penultimate stable)
- [ ] Install NGINX and required TLS dependencies (OpenSSL, etc.)
- [ ] Add `nginx` config to serve as reverse proxy to WordPress php-fpm via fastcgi/upstream (no plain HTTP exposure)
- [ ] Enforce TLS only on port 443; do not expose port 80 on the host
- [ ] Limit protocols to TLSv1.2 and TLSv1.3 only
- [ ] Use strong ciphers and modern security headers
- [ ] Mount TLS certificate and key (from generated certs) into the container
- [ ] Configure upstream to WordPress php-fpm on the internal Docker network
- [ ] Expose only `443` in Compose; do not expose other ports
- [ ] Add `healthcheck` (e.g., `curl -k https://localhost/`)

### Service: WordPress (php-fpm only, no nginx)
- [ ] Create `srcs/requirements/wordpress/Dockerfile` (Alpine/Debian penultimate stable)
- [ ] Install `php-fpm` and necessary PHP extensions for WordPress (mysqli, json, curl, mbstring, xml, zip, gd, opcache, etc.)
- [ ] Install WP-CLI (optional but recommended for setup automation)
- [ ] Configure `php-fpm` to run in foreground (proper PID 1) and listen on a network socket/port
- [ ] Download and place WordPress core into a persistent volume (site files volume)
- [ ] On first run, auto-configure `wp-config.php` via env vars and secrets
- [ ] Ensure two WordPress users exist (application-level): one admin (name must NOT contain `admin`/`administrator` in any case) and one regular user
- [ ] Create initial WP site (title, URL `https://login.42.fr`, admin user, regular user) using env vars
- [ ] Do not expose any port publicly; communicate via internal network to NGINX
- [ ] Add `healthcheck` (e.g., `php-fpm` ping or script)

### Service: MariaDB (DB only)
- [ ] Create `srcs/requirements/mariadb/Dockerfile` (Alpine/Debian penultimate stable)
- [ ] Install MariaDB server; run `mysqld` in foreground as PID 1
- [ ] Initialize database on first run in the DB volume
- [ ] Create WordPress database
- [ ] Create a dedicated DB user for WordPress with least privileges needed on the WP database
- [ ] Use secrets for root password and user passwords; no passwords in Dockerfiles
- [ ] Restrict bind/address to container only; no public exposure
- [ ] Add `healthcheck` (e.g., `mysqladmin ping`)

## Compose, Network, and Orchestration
- [ ] Write `srcs/docker-compose.yml` using Compose v3+
- [ ] Define one user-defined network for all three services
- [ ] Ensure `depends_on` and healthchecks order containers sensibly (DB → WP → NGINX)
- [ ] Set `restart` policies for all services
- [ ] Map only NGINX `443:443`; no other ports exposed to host
- [ ] Mount volumes:
  - [ ] DB volume → MariaDB data dir
  - [ ] Site volume → WordPress site files
  - [ ] Certs volume/bind → NGINX for TLS certs

## Volumes and Data
- [ ] Create host directories for volumes at `/home/login/data`:
  - [ ] `/home/login/data/mariadb` (DB data)
  - [ ] `/home/login/data/wordpress` (site files)
  - [ ] `/home/login/data/certs` (TLS cert/key)
- [ ] Ensure proper permissions and ownership for each volume dir
- [ ] Add volumes to `docker-compose.yml` with bind mounts to the above paths

## TLS and Domain
- [ ] Point `login.42.fr` to your VM’s local IP (e.g., via `/etc/hosts` for local dev)
- [ ] Generate a certificate for `login.42.fr` (self-signed or using `mkcert`)
- [ ] Store cert and key in `/home/login/data/certs` and mount into NGINX
- [ ] Configure NGINX `server` block for `login.42.fr` with TLSv1.2/1.3 only
- [ ] Optionally create HSTS and strong TLS config

## Environment and Secrets
- [ ] Create `.env` file for all non-confidential variables (e.g., domain, DB name, WP site title)
- [ ] Store confidential data in secrets (e.g., `db_root_password`, `db_password`, WP admin password)
- [ ] Reference secrets in Compose and pass to containers securely
- [ ] Ensure Dockerfiles do not `ARG` or `ENV` any sensitive secrets

## Makefile
- [ ] Implement `Makefile` targets that call Docker Compose:
  - [ ] `make build` → build all custom images via Compose (no pulling prebuilt images)
  - [ ] `make up` → start the stack in detached mode
  - [ ] `make down` → stop and remove containers, networks (keep volumes)
  - [ ] `make clean` → remove images/volumes if required by project policy
  - [ ] `make re` → clean + rebuild + up
- [ ] Ensure Make targets call `docker-compose -f srcs/docker-compose.yml ...`

## VM/Host Setup
- [ ] Ensure everything runs inside the required virtual machine environment
- [ ] Map domain `login.42.fr` to VM IP on host `/etc/hosts`
- [ ] Open only port 443 on host → NGINX
- [ ] Verify site loads at `https://login.42.fr`

## Compliance Checklist (must pass before submission)
- [ ] Each service in its own container with matching image name
- [ ] Built from penultimate stable Alpine or Debian; no `latest` tag
- [ ] Custom Dockerfiles (one per service); Makefile triggers builds
- [ ] NGINX accessible only via 443 with TLSv1.2/1.3; sole entry point
- [ ] WordPress uses php-fpm only (no NGINX inside)
- [ ] MariaDB only (no NGINX inside)
- [ ] Two WordPress users; admin username does not contain `admin`/`administrator`
- [ ] Two volumes: DB data and WordPress files (host path `/home/login/data/...`)
- [ ] Docker network declared in Compose; no `network: host`, `--link`, or `links:`
- [ ] Containers auto-restart on crash
- [ ] No hacky infinite loops or `tail -f`; correct PID 1 usage
- [ ] Passwords not present in Dockerfiles; env vars and secrets are used
- [ ] NGINX is the only exposed service; 443 only; reverse proxy to php-fpm

Tip: Start by making the DB healthy, then bring up php-fpm with a working `wp-config.php`, and finally wire NGINX TLS and upstream to php-fpm.

## Evaluation/Verification Checklist

### Simple setup
- [ ] NGINX accessible only via port 443; `https://login.42.fr` loads; `http://login.42.fr` inaccessible
- [ ] SSL/TLS certificate in use (self-signed OK); TLS v1.2/v1.3 enabled
- [ ] WordPress installed and configured (no installation page visible)

### Docker basics
- [ ] Each image uses penultimate stable `alpine:X.Y` or `debian:version`
- [ ] Image name matches its service name
- [ ] Makefile builds and starts all services via docker compose without crashes

### Docker network
- [ ] `docker-compose.yml` defines a custom user-defined network
- [ ] `docker network ls` shows the network
- [ ] Able to explain the network wiring (NGINX ↔ WordPress ↔ MariaDB)

### NGINX with SSL/TLS
- [ ] Container exists (`docker compose ps`)
- [ ] Port 80 not exposed to host; HTTP attempts fail
- [ ] `https://login.42.fr/` serves the configured WordPress site
- [ ] TLS v1.2/v1.3 demonstrated (browser or `openssl s_client`)

### WordPress with php-fpm and its volume
- [ ] Container exists (`docker compose ps`); Dockerfile contains no NGINX
- [ ] WordPress site files volume mapped under `/home/login/data/wordpress`
- [ ] Can add a comment with a regular WP user
- [ ] Admin dashboard accessible; admin username does not include `admin`/`Admin`
- [ ] Page edit from dashboard reflects on the site

### MariaDB and its volume
- [ ] Container exists (`docker compose ps`); Dockerfile contains no NGINX
- [ ] DB volume mapped under `/home/login/data/mariadb`
- [ ] Able to explain and perform DB login; database not empty (WP tables exist)

### Persistence
- [ ] After VM reboot and `docker compose up`, WordPress and MariaDB remain configured
- [ ] Prior content and changes persist (comments, edited pages)
