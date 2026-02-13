# Quick Start - T-Rex Tile Server with PostGIS

This setup serves vector tiles from a GeoPackage file loaded into PostGIS using t-rex tile server in Docker.

## What's in the data

- Original file: `data/tmpg6dthsr5.gpkg`
- Layer: `joined_max_riverlines_second` (loaded as `riverlines` in PostGIS)
- Geometry: MULTILINESTRING (river lines)
- SRID: 3857 (Web Mercator)
- Features: 43,896 river line segments
- Attributes: streamorder (1-8), rchid, relativevalues95thpercentile, etc.

## Running the server

1. Start PostGIS and t-rex containers:
```bash
docker-compose up -d
```

2. Load the geopackage data into PostGIS (first time only):
```bash
./load-data.sh
```

3. Open the built-in viewer:
```bash
open http://localhost:6767/
```

Or open the custom viewer:
```bash
open viewer.html
```

The tiles are served at: `http://localhost:6767/riverlines/{z}/{x}/{y}.pbf`

## Testing the setup

Check if t-rex is running:
```bash
curl http://localhost:6767/
```

Get tile metadata:
```bash
curl http://localhost:6767/riverlines.json
```

Test a tile:
```bash
curl -I http://localhost:6767/riverlines/0/0/0.pbf
```

## Configuration

The t-rex config (`app/trex-config.toml`) uses PostGIS with:
- Zoom-based SQL queries (fewer attributes at lower zooms for performance)
- Built-in viewer at http://localhost:6767/
- Automatic simplification based on pixel width
- Buffer zones for smooth tile boundaries

## Stopping the services

```bash
docker-compose down
```

To remove all data including the PostGIS database:
```bash
docker-compose down -v
```

## Next steps

For production AWS deployment:
1. Use the terraform configs in `infra/terraform/`
2. Set up RDS for PostGIS
3. Configure CloudFront for caching
4. Use the scripts in `scripts/` for data loading
