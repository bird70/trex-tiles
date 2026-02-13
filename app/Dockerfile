
# Build a small runtime image by copying t_rex from upstream into Alpine
FROM ghcr.io/t-rex-tileserver/t-rex:latest as upstream

FROM alpine:3.19
RUN apk add --no-cache libstdc++ proj gdal sqlite-libs postgresql-libs tzdata sed
COPY --from=upstream /usr/local/bin/t_rex /usr/local/bin/t_rex

WORKDIR /srv/trex
COPY trex-config.template.toml ./trex-config.template.toml
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6767
CMD ["/entrypoint.sh"]
