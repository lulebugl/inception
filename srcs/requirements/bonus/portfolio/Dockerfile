FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/share/portfolio
EXPOSE 8080

CMD ["python3", "-m", "http.server", "8080", "--bind", "0.0.0.0"]
