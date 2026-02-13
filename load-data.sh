#!/bin/bash
set -e

echo "🔄 Loading geopackage data into PostGIS..."

# Wait for PostGIS to be ready
echo "Waiting for PostGIS..."
until docker-compose exec -T postgis pg_isready -U postgres > /dev/null 2>&1; do
    sleep 1
done

echo "✅ PostGIS is ready"

# Load the geopackage using ogr2ogr from GDAL container
echo "Loading data from geopackage..."
docker run --rm \
    --network trex-tiles_default \
    -v $(pwd)/data:/data \
    ghcr.io/osgeo/gdal:alpine-small-latest \
    ogr2ogr \
    -f "PostgreSQL" \
    "PG:host=postgis user=postgres password=postgres dbname=gis" \
    /data/tmpg6dthsr5.gpkg \
    -nln riverlines \
    -lco GEOMETRY_NAME=geom \
    -lco FID=fid \
    -lco SPATIAL_INDEX=GIST \
    -overwrite

echo "✅ Data loaded successfully!"
echo ""
echo "Creating indexes for better performance..."

docker-compose exec -T postgis psql -U postgres -d gis <<EOF
-- Create index on streamorder for filtering
CREATE INDEX IF NOT EXISTS idx_riverlines_streamorder ON riverlines(streamorder);

-- Analyze table for query optimization
ANALYZE riverlines;

-- Show table info
SELECT 
    COUNT(*) as feature_count,
    MIN(streamorder) as min_order,
    MAX(streamorder) as max_order
FROM riverlines;
EOF

echo ""
echo "🎉 Data loading complete!"
