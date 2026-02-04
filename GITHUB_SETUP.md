# GitHub Actions Setup Guide

## Required Secrets (Repository Settings → Secrets and variables → Actions)

### Docker Hub Credentials
- **DOCKERHUB_USERNAME**: Your Docker Hub username
- **DOCKERHUB_TOKEN**: Your Docker Hub personal access token

### EC2 Deployment Credentials
- **EC2_PUBLIC_IP**: Your EC2 instance public IP address
- **EC2_SSH_KEY**: Your EC2 SSH private key (contents of your .pem file)

## Steps to Add Secrets

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret above

## CI/CD Pipeline Flow

```
Push to main
    ↓
Test (runs always)
    ↓
Build (if test passes & push event)
    ├─ Build Docker image
    ├─ Push to Docker Hub
    └─ Tag with latest + commit SHA
    ↓
Deploy (if build succeeds)
    ├─ SSH into EC2
    ├─ Install Docker (if needed)
    ├─ Pull latest image
    ├─ Stop old container
    └─ Run new container on port 80:5000
```

## No more environment blocks needed!

The pipeline now:
- ✅ Uses workflow-level secrets (automatic)
- ✅ Runs test on every push/PR
- ✅ Only builds & deploys on main branch push
- ✅ Tags images with both `latest` and commit SHA for rollback capability
