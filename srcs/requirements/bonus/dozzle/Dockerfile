FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        tar \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/amir20/dozzle/releases/download/v8.13.14/dozzle-linux-amd64.tar.gz" -o /tmp/dozzle.tgz \
    && tar -xzf /tmp/dozzle.tgz -C /usr/local/bin dozzle \
    && chmod +x /usr/local/bin/dozzle \
    && rm -f /tmp/dozzle.tgz

RUN useradd -m -s /bin/bash dozzle
RUN mkdir -p /data && chown dozzle:dozzle /data

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dozzle"]

