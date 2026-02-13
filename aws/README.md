# AWS Deployment Guide

## Architecture

```
User Browser
    ↓
CloudFront (CDN)
    ↓
├─→ S3 Bucket (Static viewer: index.html)
└─→ ALB → ECS (T-Rex tile server)
         ↓
      RDS PostGIS
```

## Deployment Steps

### 1. Deploy Infrastructure with Terraform

```bash
cd infra/terraform

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings

# Deploy
terraform init
terraform plan
terraform apply
```

### 2. Load Data into RDS PostGIS

```bash
# Get RDS endpoint from terraform output
export RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Load geopackage data
docker run --rm \
    -v $(pwd)/../../data:/data \
    ghcr.io/osgeo/gdal:alpine-small-latest \
    ogr2ogr \
    -f "PostgreSQL" \
    "PG:host=${RDS_ENDPOINT} user=postgres password=YOUR_PASSWORD dbname=gis" \
    /data/tmpg6dthsr5.gpkg \
    -nln riverlines \
    -lco GEOMETRY_NAME=geom \
    -lco FID=fid \
    -lco SPATIAL_INDEX=GIST \
    -overwrite
```

### 3. Deploy Viewer to S3

```bash
cd aws

# Update viewer.html with your CloudFront domain
# Edit line: const TILE_SERVER_URL = 'https://YOUR_CLOUDFRONT_DOMAIN_HERE.cloudfront.net';

# Deploy
export S3_BUCKET=your-viewer-bucket-name
export CLOUDFRONT_DISTRIBUTION_ID=your-distribution-id
./deploy-viewer.sh
```

### 4. Configure CloudFront

Your CloudFront distribution should have two origins:

1. **S3 Origin** (for viewer)
   - Origin: your-viewer-bucket.s3.amazonaws.com
   - Path pattern: `/` or `/index.html`
   - Behavior: Allow GET, HEAD, OPTIONS

2. **ALB Origin** (for tiles)
   - Origin: your-alb-domain.region.elb.amazonaws.com
   - Path pattern: `/riverlines/*`
   - Behavior: Allow GET, HEAD, OPTIONS
   - Cache policy: CachingOptimized

## S3 Bucket Setup

Create an S3 bucket for the viewer:

```bash
# Create bucket
aws s3 mb s3://your-viewer-bucket-name

# Enable static website hosting
aws s3 website s3://your-viewer-bucket-name \
    --index-document index.html

# Set bucket policy for public read (if not using CloudFront OAI)
cat > bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::your-viewer-bucket-name/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy \
    --bucket your-viewer-bucket-name \
    --policy file://bucket-policy.json
```

## Cost Optimization

- Use CloudFront caching to reduce tile server load
- Set appropriate cache TTLs (e.g., 1 hour for tiles)
- Consider using S3 Intelligent-Tiering for data storage
- Use RDS reserved instances for production

## Monitoring

- CloudWatch metrics for ECS tasks
- CloudFront access logs
- RDS performance insights
- Set up alarms for high error rates or latency
