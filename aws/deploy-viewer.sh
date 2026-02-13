#!/bin/bash
set -e

# Configuration
S3_BUCKET="${S3_BUCKET:-your-viewer-bucket-name}"
CLOUDFRONT_DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID:-}"

echo "📦 Deploying viewer to S3..."

# Check if bucket name is set
if [ "$S3_BUCKET" = "your-viewer-bucket-name" ]; then
    echo "❌ Error: Please set S3_BUCKET environment variable"
    echo "   Example: export S3_BUCKET=my-tile-viewer"
    exit 1
fi

# Upload viewer.html to S3
aws s3 cp viewer.html "s3://${S3_BUCKET}/index.html" \
    --content-type "text/html" \
    --cache-control "max-age=300"

echo "✅ Viewer uploaded to S3"

# Invalidate CloudFront cache if distribution ID is provided
if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo "🔄 Invalidating CloudFront cache..."
    aws cloudfront create-invalidation \
        --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
        --paths "/index.html"
    echo "✅ CloudFront cache invalidated"
fi

echo ""
echo "🎉 Deployment complete!"
echo "Viewer URL: https://${S3_BUCKET}.s3.amazonaws.com/index.html"

if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo "CloudFront URL: (check your CloudFront distribution)"
fi
