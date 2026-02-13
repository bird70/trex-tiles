
variable "project" { default = "trex-tiles" }
variable "region"  { default = "ap-southeast-2" }

# Use existing networking
variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }

# Images
variable "trex_image"   { default = "<your ECR repo>/trex-tiles:latest" }
variable "awscli_image" { default = "amazon/aws-cli:2.17.0" }

# Tile zooms
variable "minzoom" { default = 4 }
variable "maxzoom" { default = 14 }

# Optional GeoPackage sync from S3 -> EFS
variable "gpkg_bucket" { default = "" }
variable "gpkg_key"    { default = "" }
variable "sync_interval_seconds" { default = 300 }

# PostGIS connection (consider Secrets Manager)
variable "postgres_url" { default = "" }

# TLS certificates
variable "alb_acm_certificate_arn" { default = "" }
variable "cf_acm_certificate_arn"  { default = "" }

# DNS
variable "domain_name" { default = "" } # e.g., tiles.example.nz
