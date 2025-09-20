FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl php php-mysql \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/adminer
RUN curl -fsSL "https://github.com/vrana/adminer/releases/download/v5.4.0/adminer-5.4.0-en.php" \
	 -o /opt/adminer/adminer.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "/opt/adminer/adminer.php"]
