# GitHub Actions CI/CD

This project includes automated CI/CD workflows for building, testing, and deploying the tile server and viewer.

## Workflows

### 1. Build and Push Docker Image (`build-and-push.yml`)

**Triggers:**
- Push to `main`/`master` branch (when app files change)
- Pull requests
- Manual dispatch

**What it does:**
- Builds the Docker image for the t-rex tile server
- Pushes to Amazon ECR (on main branch only)
- Uses Docker layer caching for faster builds

**Required Secrets:**
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

**Configuration:**
- Update `AWS_REGION` in workflow file (default: us-east-1)
- Update `ECR_REPOSITORY` name (default: trex-tileserver)

### 2. Deploy Viewer to S3 (`deploy-viewer.yml`)

**Triggers:**
- Push to `main`/`master` branch (when viewer.html changes)
- Manual dispatch with environment selection

**What it does:**
- Updates viewer.html with CloudFront URL
- Uploads to S3 bucket
- Invalidates CloudFront cache

**Required Secrets:**
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `S3_VIEWER_BUCKET` - S3 bucket name for viewer
- `CLOUDFRONT_URL` - CloudFront domain (e.g., d123abc.cloudfront.net)
- `CLOUDFRONT_DISTRIBUTION_ID` - CloudFront distribution ID (optional)

### 3. Terraform CI/CD (`terraform.yml`)

**Triggers:**
- Push to `main`/`master` branch (when terraform files change)
- Pull requests (runs plan only)
- Manual dispatch with action selection (plan/apply/destroy)

**What it does:**
- Validates Terraform configuration
- Runs `terraform plan` on PRs
- Can apply or destroy infrastructure (manual dispatch only)
- Comments plan output on pull requests

**Required Secrets:**
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

## Setup Instructions

### 1. Configure AWS Credentials

Add these secrets to your GitHub repository:

```
Settings → Secrets and variables → Actions → New repository secret
```

Required secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 2. Create ECR Repository

```bash
aws ecr create-repository \
    --repository-name trex-tileserver \
    --region us-east-1
```

### 3. Create S3 Bucket for Viewer

```bash
# Create bucket
aws s3 mb s3://your-viewer-bucket-name

# Enable static website hosting
aws s3 website s3://your-viewer-bucket-name \
    --index-document index.html

# Set bucket policy (adjust as needed)
aws s3api put-bucket-policy \
    --bucket your-viewer-bucket-name \
    --policy file://bucket-policy.json
```

### 4. Add Deployment Secrets

Add these additional secrets:

- `S3_VIEWER_BUCKET` - Your S3 bucket name
- `CLOUDFRONT_URL` - Your CloudFront domain (without https://)
- `CLOUDFRONT_DISTRIBUTION_ID` - Your CloudFront distribution ID (optional)

### 5. Configure Terraform Backend (Optional)

For team collaboration, configure remote state:

```hcl
# infra/terraform/backend.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "trex-tiles/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Usage

### Automatic Deployments

1. **Push to main branch** - Automatically builds and pushes Docker image to ECR
2. **Update viewer** - Push changes to `aws/viewer.html` to auto-deploy to S3
3. **Update infrastructure** - Create PR with terraform changes to see plan

### Manual Deployments

#### Deploy Viewer
```
Actions → Deploy Viewer to S3 → Run workflow
```

#### Apply Terraform Changes
```
Actions → Terraform CI/CD → Run workflow → Select "apply"
```

#### Build Docker Image
```
Actions → Build and Push Docker Image → Run workflow
```

## GitHub Free Tier Limitations

The GitHub Free plan includes:
- 2,000 CI/CD minutes per month
- 500 MB of package storage

**Note:** These workflows are designed to be efficient and should work within free tier limits for small projects. However:

- Docker builds can be time-consuming (5-10 minutes)
- Consider using self-hosted runners for larger projects
- ECR storage is billed separately by AWS

## Workflow Optimization Tips

1. **Use caching** - Docker layer caching is enabled
2. **Limit triggers** - Workflows only run when relevant files change
3. **Manual deploys** - Use workflow_dispatch for controlled deployments
4. **PR previews** - Terraform plans are commented on PRs

## Troubleshooting

### ECR Push Fails
- Verify AWS credentials are correct
- Ensure ECR repository exists
- Check IAM permissions for ECR push

### S3 Deploy Fails
- Verify S3 bucket exists and is accessible
- Check bucket policy allows uploads
- Ensure AWS credentials have S3 write permissions

### Terraform Fails
- Check terraform syntax: `terraform validate`
- Verify AWS credentials have necessary permissions
- Review terraform plan output for errors

## Security Best Practices

1. **Use least privilege IAM policies** - Only grant necessary permissions
2. **Rotate credentials regularly** - Update GitHub secrets periodically
3. **Enable branch protection** - Require PR reviews before merging
4. **Use environments** - Configure GitHub environments for production deployments
5. **Scan for secrets** - Enable GitHub secret scanning

## Next Steps

1. Set up GitHub Environments for staging/production
2. Add automated testing before deployment
3. Configure deployment approvals for production
4. Set up monitoring and alerting
5. Add rollback capabilities
