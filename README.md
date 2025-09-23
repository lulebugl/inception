## Inception

A Docker-Compose based mini-infrastructure with three services: NGINX (TLS-only), WordPress (php-fpm only), and MariaDB (DB only). All services run in separate containers built from your own Dockerfiles, using Alpine or Debian (penultimate stable versions). No ready-made images (besides base OS) and no hacky infinite-loop entrypoints.

Replace `login` with your 42 login everywhere (e.g., volumes path `/home/login/data`, domain `login.42.fr`).

## Last
- [ ] should i make everything go through https with reverse proxy?
      not exposing additional ports
- [ ] do i forget about mkcerts?
- [?] Can add a comment with a regular WP user (check correction again)

### Useful commands

```bash
# Verify TLS protocols
openssl s_client -connect login.42.fr:443 -tls1_2 | head -n 20
openssl s_client -connect login.42.fr:443 -tls1_3 | head -n 20

curl -vkI https://login.42.fr
curl -v http://login.42.fr  # should fail

# Network / volumes
docker volume ls
docker volume inspect <volume-name>

# to debug container
docker compose -f srcs/docker-compose.yml run --rm --no-deps --entrypoint bash service

# check redis status
docker exec -it wordpress wp redis status --allow-root

# example cmd for ftp
echo "ftp demo $(date)" >/tmp/ftp-demo.txt
curl -v --ftp-pasv --user "www-data:$PASS" -T /tmp/ftp-demo.txt \
  ftp://127.0.0.1:21/wp-content/uploads/ftp-demo.txt
```

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
