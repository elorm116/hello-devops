# Contributing & Development Guide

## Local Development

### Setup
```bash
# Clone repo
git clone <repo-url>
cd hello-devops

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install pytest

# Run tests locally
python3 -m pytest tests/ -v

# Run app locally
python app.py  # Runs on localhost:5000
```

### Docker Local Testing
```bash
docker build -t hello-devops:test .
docker run -d -p 5000:5000 hello-devops:test
curl localhost:5000
```

### Local Monitoring Stack (Optional)
```bash
cd monitoring
docker compose up -d
# Grafana: http://localhost:3000
# Prometheus: http://localhost:9090
# Kibana: http://localhost:5601
```

## Making Changes

### 1. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes
- Edit code
- Add tests for new functionality
- Update README if needed
- Update ARCHITECTURE.md if changing infrastructure

### 3. Test Locally
```bash
# Run unit tests
pytest tests/ -v

# Build and test Docker image
docker build -t hello-devops:test .
docker run -it hello-devops:test

# Test with monitoring (optional)
cd monitoring && docker compose up -d
```

### 4. Commit & Push
```bash
git add .
git commit -m "Brief description of changes"
git push origin feature/your-feature-name
```

### 5. Create Pull Request
- Push to your branch on GitHub
- Create PR against main
- Wait for GitHub Actions tests to pass
- Request review if applicable

### 6. Merge & Deploy
- Once merged to main, CI/CD triggers automatically
- GitHub Actions will test → build → deploy in sequence
- Deploy job pushes new image to Docker Hub and SSH deploys to EC2

## Terraform Workflow

### For Infrastructure Changes
```bash
cd terraform

# 1. Update .tf files
# 2. Validate syntax
terraform validate

# 3. See what changes will be made
terraform plan

# 4. Apply changes
terraform apply

# 5. Commit changes
git add terraform/
git commit -m "Infrastructure: describe what changed"
git push origin main
```

### Important Notes
- Always run `terraform plan` before apply
- Never commit terraform.tfvars with secrets
- Use variables.tf for configurable values
- Update outputs.tf when adding new resources
- Test in dev environment first if possible

## Monitoring Stack Verification

### After Deploying to EC2
```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@<EC2-IP>

# Check containers
docker ps

# View logs
docker logs app
docker logs prometheus
docker logs grafana
docker logs kibana
docker logs elasticsearch
docker logs logstash
```

### Check Application
- Application: http://<EC2-IP> (should see "Hello DevOps!")
- CloudWatch Dashboard: AWS Console → CloudWatch → Dashboards

### Check Grafana/Prometheus
- Grafana: http://<EC2-IP>:3000 (login: admin/admin)
  - Should show Prometheus data source
  - Check dashboards for metrics
- Prometheus: http://<EC2-IP>:9090
  - Should show targets "up"
  - Can query metrics manually

### Check Kibana
- Kibana: http://<EC2-IP>:5601
  - Should show log indices from Elasticsearch
  - Can search logs from Logstash

### Check CloudWatch Alarms
- AWS Console → CloudWatch → Alarms
  - Should see 4 alarms (CPU, Memory, Disk, Status Check)
  - Check if any are in ALARM state

## Troubleshooting

### Tests Failing
```bash
# Run pytest locally
pytest tests/ -v

# Check Python version (should be 3.11+)
python --version

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### Docker Build Issues
```bash
# Clean up old images
docker rmi hello-devops:test

# Rebuild from scratch
docker build -t hello-devops:test --no-cache .

# Check Dockerfile for errors
cat Dockerfile
```

### Monitoring Stack Not Starting
```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@<EC2-IP>

# Check individual containers
docker logs elasticsearch
docker logs kibana
docker logs prometheus
docker logs grafana

# Check disk space
df -h

# Check memory
free -h

# Restart monitoring stack
cd /opt/hello-devops
docker compose restart
```

### Terraform Issues
```bash
# Validate configuration
terraform validate

# Check state
terraform state list

# Debug specific resource
terraform state show aws_instance.web
```

## Code Standards

### Python
- Use PEP 8 style guide
- Type hints where possible
- Docstrings for functions
- Test coverage for new features

### Terraform
- Use consistent formatting (terraform fmt)
- Add descriptions to variables/outputs
- Use locals for repeated values
- Follow naming conventions (aws_resource_type)

### YAML (GitHub Actions)
- Consistent indentation (2 spaces)
- Clear job names and descriptions
- Add comments for complex steps
- Use secrets for sensitive data

### Markdown
- Use consistent heading levels
- Code blocks with language tags
- Clear section organization

## Release Process

1. **Update version** in code/README if needed
2. **Create tag**: `git tag -a v1.0.0 -m "Release 1.0.0"`
3. **Push tag**: `git push origin v1.0.0`
4. **Automatic**: CI/CD builds image with version tag and deploys

## Getting Help

- **README.md** - Project overview and quick start
- **ARCHITECTURE.md** - System design and data flows
- **DEPLOYMENT_CHECKLIST.md** - Step-by-step deployment guide
- **START_HERE.md** - For understanding the project
- **Terraform files** - Infrastructure documentation
- **GitHub Actions logs** - For CI/CD debugging

## Additional Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
