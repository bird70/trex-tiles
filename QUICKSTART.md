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

3. View the map:
   - **Custom viewer**: http://localhost:6767/index.html
   - **Built-in t-rex viewer**: http://localhost:6767/
   - **Standalone file**: Open `viewer.html` in your browser

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

Test the custom viewer:
```bash
curl -I http://localhost:6767/index.html
```

## Configuration

The t-rex config (`app/trex-config.toml`) uses PostGIS with:
- Zoom-based SQL queries (fewer attributes at lower zooms for performance)
- Built-in viewer at http://localhost:6767/
- Custom viewer served from `/srv/trex/static/`
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

## AWS Deployment

For production deployment to AWS:

1. See `aws/README.md` for complete deployment guide
2. The viewer in `aws/viewer.html` is ready for S3 static hosting
3. Use `aws/deploy-viewer.sh` to deploy to S3
4. Configure CloudFront to serve both tiles (from ALB/ECS) and viewer (from S3)

Quick overview:
- **Viewer**: S3 bucket + CloudFront
- **Tiles**: ECS Fargate + ALB + CloudFront
- **Data**: RDS PostGIS

See terraform configs in `infra/terraform/` for infrastructure setup.
