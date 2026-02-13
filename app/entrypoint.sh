
#!/bin/sh
set -e
: "${POSTGRES_URL:?Need POSTGRES_URL}"
: "${MINZOOM:=4}"
: "${MAXZOOM:=14}"

# Render config from template
sed -e "s|__POSTGRES_URL__|${POSTGRES_URL}|g"     -e "s|__MINZOOM__|${MINZOOM}|g"     -e "s|__MAXZOOM__|${MAXZOOM}|g"     trex-config.template.toml > trex-config.toml

exec /usr/local/bin/t_rex serve --config /srv/trex/trex-config.toml
