# Viewer Deployment Options

This project provides three ways to view your vector tiles, each suited for different use cases.

## Option 1: Local Development (Current Setup)

**Access**: http://localhost:6767/index.html

**How it works**:
- Viewer is served directly by t-rex from `/srv/trex/static/`
- Everything runs in Docker containers
- No external hosting needed

**Best for**:
- Local development and testing
- Quick demos
- Internal use

**Setup**:
```bash
docker-compose up -d
./load-data.sh
open http://localhost:6767/index.html
```

## Option 2: Standalone HTML File

**Access**: `file:///path/to/viewer.html`

**How it works**:
- Open `viewer.html` directly in your browser
- Connects to tile server at localhost:6767
- No web server needed

**Best for**:
- Quick local testing
- Sharing with team members (they need tile server running)

**Setup**:
```bash
open viewer.html
# or double-click the file
```

## Option 3: AWS Production (S3 + CloudFront)

**Access**: https://your-domain.com/

**How it works**:
- Viewer hosted in S3 bucket as static website
- Served through CloudFront CDN
- Tiles served from ECS/ALB through same CloudFront distribution
- Fully scalable and production-ready

**Architecture**:
```
Browser
   ↓
CloudFront (CDN)
   ├─→ S3 (viewer HTML)
   └─→ ALB → ECS (t-rex) → RDS PostGIS
```

**Best for**:
- Production deployments
- Public-facing applications
- High traffic scenarios
- Global distribution

**Setup**:
1. Deploy infrastructure with Terraform (see `infra/terraform/`)
2. Update `aws/viewer.html` with your CloudFront domain
3. Deploy viewer: `cd aws && ./deploy-viewer.sh`
4. Load data into RDS PostGIS

**Files**:
- `aws/viewer.html` - Production-ready viewer
- `aws/deploy-viewer.sh` - Deployment script
- `aws/README.md` - Complete deployment guide

## Comparison

| Feature | Local (t-rex) | Standalone | AWS (S3+CF) |
|---------|--------------|------------|-------------|
| Setup complexity | Low | Minimal | High |
| Cost | Free | Free | $$ |
| Scalability | Single machine | N/A | Unlimited |
| Public access | No | No | Yes |
| CDN caching | No | No | Yes |
| HTTPS | No | No | Yes |
| Custom domain | No | No | Yes |

## Recommendation

- **Development**: Use Option 1 (local t-rex)
- **Testing/Demos**: Use Option 2 (standalone file)
- **Production**: Use Option 3 (AWS S3 + CloudFront)

## Next Steps

1. Test locally with Option 1
2. When ready for production, follow `aws/README.md`
3. Configure your domain and SSL certificate
4. Set up monitoring and alerts
