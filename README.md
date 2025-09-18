## Inception

A Docker-Compose based mini-infrastructure with three services: NGINX (TLS-only), WordPress (php-fpm only), and MariaDB (DB only). All services run in separate containers built from your own Dockerfiles, using Alpine or Debian (penultimate stable versions). No ready-made images (besides base OS) and no hacky infinite-loop entrypoints.

Replace `login` with your 42 login everywhere (e.g., volumes path `/home/login/data`, domain `login.42.fr`).

## Next
* create config file for php-fpm and wordpress

## Global TODO
- [ ] Create a dedicated Docker network in `docker-compose.yml` (no host network, no links)
- [ ] Ensure each service image name matches its service name
- [ ] Avoid the `latest` tag everywhere
- [ ] Set `restart` policy for all containers (e.g., `always` or `unless-stopped`)
- [ ] Verify proper PID 1 handling in each container (use native daemons or correct foreground mode)
- [ ] Add .env to .gitignore and changes the value before finishing the project
- [ ] use mkcert to trust local CA before correction

### Service: NGINX (sole entry point on 443 with TLSv1.2/1.3)
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
- [x] Install MariaDB server; run `mysqld` in foreground as PID 1
- [x] Initialize database on first run in the DB volume
- [x] Create WordPress database
- [x] Create a dedicated DB user for WordPress with least privileges needed on the WP database
- [x] Use secrets for root password and user passwords; no passwords in Dockerfiles
- [\] Restrict bind/address to container only; no public exposure
- [x] Add `healthcheck` (e.g., `mysqladmin ping`)

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
- [\] Create host directories for volumes at `/home/login/data`:
  - [x] `/home/login/data/mariadb` (DB data)
  - [x] `/home/login/data/wordpress` (site files)
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
- [x] Container exists (`docker compose ps`); Dockerfile contains no NGINX
- [ ] DB volume mapped under `/home/login/data/mariadb`
- [ ] Able to explain and perform DB login; database not empty (WP tables exist)

### Persistence
- [ ] After VM reboot and `docker compose up`, WordPress and MariaDB remain configured
- [ ] Prior content and changes persist (comments, edited pages)

## Documentation

### Docker and Compose
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Compose file reference](https://docs.docker.com/compose/compose-file/)
- [HEALTHCHECK (Dockerfile)](https://docs.docker.com/reference/dockerfile/#healthcheck) · [Compose healthcheck](https://docs.docker.com/compose/compose-file/05-services/#healthcheck)
- [Environment variables in Compose](https://docs.docker.com/compose/environment-variables/set-environment-variables/)
- [Secrets in Compose](https://docs.docker.com/compose/use-secrets/)

### NGINX TLS and FastCGI
- [Configuring HTTPS servers](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [FastCGI module (php-fpm)](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)
- [Mozilla SSL/TLS config generator](https://ssl-config.mozilla.org/)

### PHP-FPM and WordPress
- [php-fpm configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [WordPress requirements](https://wordpress.org/support/article/requirements/)
- [WP-CLI](https://wp-cli.org/)
- [Editing wp-config.php](https://wordpress.org/documentation/article/editing-wp-config-php/)

### MariaDB
- [Initialize data directory](https://mariadb.com/kb/en/mysql_install_db/)
- [mysqld options](https://mariadb.com/kb/en/mysqld-options/)
- [GRANT privileges](https://mariadb.com/kb/en/grant/)

### TLS tools and local certs
- [mkcert](https://github.com/FiloSottile/mkcert)

### Useful commands

```bash
# Verify TLS protocols
openssl s_client -connect login.42.fr:443 -tls1_2 | head -n 20
openssl s_client -connect login.42.fr:443 -tls1_3 | head -n 20

# Check endpoints
curl -vkI https://login.42.fr
curl -v http://login.42.fr  # should fail

# Compose / containers
docker compose ps
docker compose logs -f | cat

# Network / volumes
docker network ls
docker volume ls
docker volume inspect <volume-name>

# to debug container
docker compose -f srcs/docker-compose.yml run --rm --no-deps --entrypoint bash service
```
