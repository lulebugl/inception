FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
	   curl \
	   nginx \
	   openssl \
	   gettext-base \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/cache/nginx /etc/nginx/conf.d /etc/nginx/templates

COPY conf/nginx.conf /etc/nginx/templates/nginx.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

