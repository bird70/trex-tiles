
# t-rex tiles on AWS (ECS Fargate + ALB + CloudFront)

This repo deploys a lightweight **t-rex** vector tile server to AWS, fronted by **CloudFront**, and shows how to connect it from **MapLibre GL JS**.

Two data paths are supported:

1. **PostGIS (recommended)** — best performance for ~2M lines; supports zoom-aware generalization in SQL.
2. **GeoPackage on S3 (optional)** — sidecar sync into a shared volume (EFS), suitable for small teams and quick updates.

## Structure

```
app/                        # t-rex container files
  Dockerfile                # builds a small runtime image with t_rex and entrypoint
  entrypoint.sh             # injects env vars into trex-config at runtime
  trex-config.template.toml # PostGIS config template (env placeholders)
  demo-index.html           # MapLibre demo pointing at CloudFront
infra/terraform/            # Terraform: ECS, ALB, CloudFront, IAM, EFS (optional)
  providers.tf
  variables.tf
  iam.tf
  networking.tf             # SGs and EFS (if using GeoPackage)
  ecs.tf
  alb.tf
  cloudfront.tf
  outputs.tf
scripts/
  gpkg_to_postgis.sh        # one-off or scheduled ingest from GeoPackage -> PostGIS
  create_postgis_indexes.sql
```

## Quick start (high level)

1. **Provision PostGIS** (RDS) and load your data (see `scripts/`).
2. **Configure Terraform** vars (VPC/Subnet IDs, cert ARNs, domain).
3. **Build & push** the app image (or use the upstream image).
4. **terraform apply** in `infra/terraform`.
5. Open the CloudFront domain and the **demo-index.html** locally to verify tiles render.

See inline comments in Terraform for details and hardening options.
