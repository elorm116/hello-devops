# Deployment Checklist & Quick Reference

## ✅ Pre-Deployment Checklist

- [ ] AWS account created with $1+ budget
- [ ] EC2 key pair created and downloaded (.pem file)
- [ ] GitHub repository forked/created
- [ ] Docker Hub account created
- [ ] Personal access token created in Docker Hub

## 📋 Configuration Steps

### Step 1: GitHub Secrets (5 min)

Go to: `Settings → Secrets and variables → Actions`

Add these secrets:
```
DOCKERHUB_USERNAME = your-dockerhub-username
DOCKERHUB_TOKEN = your-dockerhub-pat
EC2_PUBLIC_IP = (will get after terraform apply)
EC2_SSH_KEY = (copy paste contents of your .pem file)
```

### Step 2: Terraform Variables (5 min)

Edit `terraform/terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
project_name = "hello-devops"
environment  = "dev"
key_name     = "your-key-name"    # EC2 key pair name in AWS
my_ip        = "YOUR.IP.HERE/32"  # Your IP for SSH
alert_email  = "you@email.com"    # For alarms
```

Get your IP: `curl ipinfo.io/ip`

### Step 3: Deploy Infrastructure (10-15 min)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**Copy output values:**
- Instance Public IP
- Application URL
- Dashboard URL

### Step 4: Update GitHub Secrets with EC2 IP (1 min)

Update `EC2_PUBLIC_IP` secret with the IP from Step 3.

### Step 5: Push to Main (3 min)

```bash
git add .
git commit -m "Deploy monitoring stack and fix CI/CD"
git push origin main
```

GitHub Actions will:
1. Run tests
2. Build & push Docker image
3. Deploy to EC2

## 🌐 Access Points After Deployment

| Service | URL | Credentials |
|---------|-----|-------------|
| **Application** | `http://<EC2-IP>` | Public |
| **Grafana** | `http://<EC2-IP>:3000` | admin/admin (change!) |
| **Prometheus** | `http://<EC2-IP>:9090` | Public |
| **Kibana** | `http://<EC2-IP>:5601` | Public |
| **CloudWatch** | AWS Console | Your AWS login |

Wait 3-5 minutes after deployment for monitoring stack to initialize.

## 🐛 Verification

### Check EC2 Status
```bash
ssh -i your-key.pem ec2-user@<EC2-IP>
docker ps  # See all containers
docker logs -f app  # Follow app logs
```

### Check CI/CD Pipeline
1. Go to GitHub repo → Actions
2. Watch the workflow run
3. Each job should show:
   - ✅ test: success
   - ✅ build: success
   - ✅ deploy: success

### Check Monitoring
1. Visit `http://<EC2-IP>:3000` (Grafana)
2. Check dashboards loading
3. Visit CloudWatch dashboard from terraform output

## 💾 Important Files

- **`terraform/terraform.tfvars`** - UPDATE THIS with your values
- **`.github/workflows/ci-cd.yml`** - CI/CD pipeline (read-only)
- **`GITHUB_SETUP.md`** - Detailed GitHub secrets guide
- **`README.md`** - Full documentation

## 🛑 Stop Everything (Delete Resources)

```bash
cd terraform
terraform destroy -auto-approve
```

⚠️ **This deletes all AWS resources.** Only run if you want to stop charges.

## 🆘 Stuck?

1. **Check GitHub Actions logs**: Actions tab → workflow run → click job for details
2. **Check EC2 logs**: `ssh ...` then `docker compose logs -f`
3. **Check Terraform errors**: `terraform apply` output has details
4. **Check security groups**: Verify ports are open from your IP

## 📊 Cost Monitoring

AWS Console → Billing & Cost Management → Cost Explorer

Expected: ~$0.90/month
Budget alert set to: $1.00

You'll get notified if you exceed $1.
