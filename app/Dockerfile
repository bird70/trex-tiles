
FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    libgdal28 \
    libsqlite3-0 \
    libpq5 \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install t-rex binary
RUN curl -L https://github.com/t-rex-tileserver/t-rex/releases/download/v0.14.3/t-rex-v0.14.3-x86_64-linux-gnu.tar.gz \
    -o /tmp/t-rex.tar.gz && \
    tar xzf /tmp/t-rex.tar.gz -C /usr/local/bin && \
    rm /tmp/t-rex.tar.gz && \
    chmod +x /usr/local/bin/t_rex

WORKDIR /srv/trex
COPY trex-config.toml ./trex-config.toml

EXPOSE 6767
CMD ["/usr/local/bin/t_rex", "serve", "--config", "/srv/trex/trex-config.toml"]
