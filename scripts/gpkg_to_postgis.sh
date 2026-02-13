
#!/usr/bin/env bash
set -euo pipefail
# Usage: ./gpkg_to_postgis.sh your.gpkg your_layer postgresql://user:pass@host:5432/dbname
GPKG=${1:?path to gpkg}
LAYER=${2:?layer name in gpkg}
PGURL=${3:?postgres connection string}
SCHEMA=${SCHEMA:-public}
TABLE=${TABLE:-lines}

ogr2ogr -f PostgreSQL   "${PGURL}" "${GPKG}"   -nln ${SCHEMA}.${TABLE}   -nlt LINESTRING   -lco GEOMETRY_NAME=geom   -lco FID=id   -t_srs EPSG:4326   -progress   -overwrite   ${LAYER}

psql "${PGURL}" -f create_postgis_indexes.sql
