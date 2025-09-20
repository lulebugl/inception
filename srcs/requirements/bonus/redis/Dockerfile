FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        redis-server \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 6379

RUN sed -i 's/^#\?bind .*/bind 0.0.0.0/' /etc/redis/redis.conf

RUN echo "maxmemory 256mb" >> /etc/redis/redis.conf
RUN echo "maxmemory-policy allkeys-lru" >> /etc/redis/redis.conf


CMD ["redis-server", "--protected-mode", "no", "--appendonly", "yes"]
