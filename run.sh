#!/bin/bash
set -e

echo "🚀 Starting T-Rex Tile Server with GeoPackage"
echo ""
echo "Data: 43,896 river line features from joined_max_riverlines_second"
echo "SRID: 3857 (Web Mercator)"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

echo "✅ Docker is running"
echo ""
echo "Building and starting t-rex container..."
docker-compose up --build

echo ""
echo "🎉 T-Rex is running!"
echo ""
echo "View tiles at: http://localhost:6767/"
echo "Open viewer.html in your browser to see the map"
