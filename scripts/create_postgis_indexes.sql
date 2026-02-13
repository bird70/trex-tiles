
-- One-time prep for performance
CREATE EXTENSION IF NOT EXISTS postgis;
ALTER TABLE lines ADD COLUMN IF NOT EXISTS geom_webmercator geometry(LineString, 3857);
UPDATE lines SET geom_webmercator = ST_Transform(geom, 3857) WHERE geom_webmercator IS NULL;
CREATE INDEX IF NOT EXISTS idx_lines_geom_webmercator ON lines USING GIST (geom_webmercator);
ANALYZE lines;
