# Hello DevOps - Complete Cloud Infrastructure & Monitoring Project

A production-ready DevOps project demonstrating AWS infrastructure automation, CI/CD pipelines, monitoring, and logging.

## 📋 Project Overview

This project implements everything needed for a modern DevOps portfolio:

### ✅ What's Included

#### 1. **Cloud Infrastructure as Code (Terraform)**
- AWS VPC with public subnet and Internet Gateway
- EC2 instance (t2.micro, optimized for $1 budget)
- Security groups with least-privilege access
- IAM roles with fine-grained CloudWatch permissions
- S3 backend for Terraform state management
- DynamoDB for Terraform state locking

#### 2. **CI/CD Pipeline (GitHub Actions)**
- Automated testing on every push/PR
- Docker image build and push to Docker Hub
- Automatic deployment to EC2 on main branch push
- Versioned images (tagged with commit SHA for rollback)

#### 3. **Monitoring & Observability**
- **AWS CloudWatch**: Metrics collection, log aggregation
- **CloudWatch Dashboards**: Real-time infrastructure metrics
- **CloudWatch Alarms**: Email alerts for CPU, Memory, Disk, Status Check
- **Prometheus**: Custom metrics scraping
- **Grafana**: Dashboard visualization
- **ELK Stack**: Elasticsearch + Logstash + Kibana for log analysis

#### 4. **Application**
- Python Flask web app
- Containerized with Docker
- Runs on port 80 (HTTP) → 5000 (app)

---

## 🚀 Quick Start

### Prerequisites
- AWS Account with $1+ budget
- GitHub account
- Docker Hub account
- SSH key pair for EC2 access

### 1. GitHub Setup (5 minutes)

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

**Docker Hub:**
- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Your Docker Hub personal access token

**EC2 Deployment:**
- `EC2_PUBLIC_IP`: Your EC2 instance public IP (you'll get this after Terraform apply)
- `EC2_SSH_KEY`: Contents of your EC2 private key file (.pem)

See [GITHUB_SETUP.md](GITHUB_SETUP.md) for detailed steps.

### 2. Terraform Configuration (5 minutes)

Edit `terraform/terraform.tfvars`:

```hcl
aws_region  = "us-east-1"
project_name = "hello-devops"
environment  = "dev"
key_name     = "your-ec2-key-pair"  # Name of your EC2 key pair in AWS
my_ip        = "1.2.3.4/32"          # Your IP for SSH access
alert_email  = "you@example.com"     # For CloudWatch alarm notifications
```

### 3. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**Output includes:**
- `application_url`: Direct access to your app
- `instance_public_ip`: Your EC2 public IP
- `cloudwatch_dashboard_url`: CloudWatch dashboard

### 4. Access Monitoring Stack

After deployment (wait 3-5 minutes for containers to start):

**CloudWatch (AWS Native):**
- Dashboard: https://console.aws.amazon.com/cloudwatch (see output URL)
- Logs: /aws/ec2/hello-devops

**Grafana (On EC2):**
- URL: `http://<EC2-IP>:3000`
- Default creds: admin/admin (change immediately!)
- Pre-configured for Prometheus

**Prometheus:**
- URL: `http://<EC2-IP>:9090`
- Metrics: `:9090/metrics`

**Kibana (Log Analysis):**
- URL: `http://<EC2-IP>:5601`
- Index: `app-logs-*`

---

## 📊 Monitoring Stack Architecture

```
EC2 Instance (t2.micro)
├── Docker App (Port 80 → 5000)
├── Prometheus (Port 9090)
│   └─ Scrapes metrics from CloudWatch + node exporter
├── Grafana (Port 3000)
│   └─ Visualizes Prometheus metrics
├── Elasticsearch (Port 9200)
│   └─ Stores logs
├── Logstash (Port 5044)
│   └─ Processes and ships logs
└── Kibana (Port 5601)
    └─ Queries and displays logs

+ CloudWatch (AWS)
  ├─ Collects custom metrics (Memory, Disk, CPU)
  ├─ Aggregates logs
  ├─ Displays in Dashboard
  └─ Triggers Alarms → SNS → Email
```

---

## 🔄 CI/CD Pipeline Flow

```
1. Push code to main branch
   ↓
2. GitHub Actions triggers
   ├─ Test: Run pytest
   │  └─ Fail = Stop, Fix = Continue
   │
   ├─ Build: (if test passed)
   │  ├─ Build Docker image
   │  ├─ Push to Docker Hub (latest + commit SHA)
   │  └─ Success = Continue
   │
   └─ Deploy: (if build succeeded)
      ├─ SSH into EC2
      ├─ Pull latest image
      ├─ Stop old container
      └─ Run new container

Result: Live app update in ~2-3 minutes
```

---

## 🔐 Security & Best Practices

### ✅ Implemented

- **Least-privilege IAM**: Custom policy instead of broad managed policies
- **SSH Key-based Auth**: No passwords, only EC2 key pairs
- **Security Groups**: Restrictive ingress (SSH only from your IP)
- **Encryption**: S3 state encryption enabled
- **State Locking**: DynamoDB prevents concurrent changes
- **No hardcoded secrets**: Everything in GitHub Actions secrets

### 📌 Alarms

Configured alerts (email via SNS):
- CPU > 80%
- Memory > 80%
- Disk > 80%
- Status Check Failed

---

## 💰 Cost Management

**Your $1 Budget Breakdown:**

| Service | Cost/Month |
|---------|-----------|
| EC2 t2.micro | $0.50 |
| CloudWatch logs | $0.10 |
| CloudWatch alarms | $0.10 |
| S3 + DynamoDB | $0.20 |
| **Total** | **~$0.90** |

✅ Stays under $1 budget (rough estimates, varies by region)

---

## 📁 Project Structure

```
hello-devops/
├── app.py                          # Flask application
├── Dockerfile                      # App container image
├── docker-compose.yaml             # Local dev environment
├── requirements.txt                # Python dependencies
├── GITHUB_SETUP.md                # GitHub Actions secrets guide
├── .github/workflows/
│   └── ci-cd.yml                  # CI/CD pipeline definition
├── terraform/                     # Infrastructure as Code
│   ├── main.tf                    # Provider config
│   ├── networking.tf              # VPC, subnets, IGW
│   ├── instance.tf                # EC2 configuration
│   ├── security-groups.tf         # Security groups (web)
│   ├── monitoring-sg.tf           # Security group (monitoring)
│   ├── iam.tf                     # IAM roles & policies
│   ├── cloudwatch.tf              # CloudWatch log group
│   ├── dashboard.tf               # CloudWatch dashboard
│   ├── alarms.tf                  # CloudWatch alarms
│   ├── userdata.tftpl             # Original user data script
│   ├── userdata-monitoring.tftpl  # User data with monitoring stack
│   ├── setup-backend.tf           # S3 + DynamoDB backend
│   ├── backend.tf                 # Remote state config
│   ├── variables.tf               # Variable definitions
│   ├── terraform.tfvars           # Variable values (CONFIGURE THIS)
│   └── outputs.tf                 # Output values
├── monitoring/
│   ├── docker-compose.yml         # Prometheus, Grafana, ELK
│   ├── prometheus.yml             # Prometheus config
│   └── logstash.conf              # Logstash config
└── tests/
    └── test_app.py                # Application tests
```

---

## 🛠 Common Tasks

### View Application Logs
```bash
ssh -i your-key.pem ec2-user@<EC2-IP>
docker logs -f app
```

### Restart Monitoring Stack
```bash
ssh -i your-key.pem ec2-user@<EC2-IP>
cd /opt/hello-devops
docker compose -f monitoring/docker-compose.yml restart
```

### SSH into EC2
```bash
ssh -i your-ec2-key.pem ec2-user@<EC2-PUBLIC-IP>
```

### Destroy Everything (Stop Costs)
```bash
cd terraform
terraform destroy
```

---

## 📈 CV Alignment

This project demonstrates:

✅ **Cloud Infrastructure & Automation**
- AWS (EC2, VPC, S3, IAM) ✓
- Terraform IaC ✓
- Security & least-privilege principles ✓

✅ **CI/CD Pipelines**
- GitHub Actions ✓
- Docker build & push ✓
- Automated deployment ✓

✅ **Monitoring, Logging & Reliability**
- AWS CloudWatch (metrics + logs) ✓
- Dashboards (CloudWatch + Grafana) ✓
- Alerts & incident response setup ✓
- Prometheus + Grafana + ELK Stack ✓

---

## 🐛 Troubleshooting

### Monitoring stack didn't start
```bash
ssh -i your-key.pem ec2-user@<EC2-IP>
cd /opt/hello-devops
docker compose -f monitoring/docker-compose.yml logs -f
```

### Can't access Grafana/Prometheus/Kibana
- Check security group allows access from your IP on ports 3000, 9090, 5601
- Wait 3-5 minutes for containers to initialize
- Check container status: `docker ps`

### Deployment failing via CI/CD
- Verify `EC2_SSH_KEY` secret contains full private key contents
- Check `EC2_PUBLIC_IP` is correct and accessible
- Verify security group allows SSH from GitHub Actions runners

---

## 📚 Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [AWS CloudWatch](https://docs.aws.amazon.com/cloudwatch/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
- [ELK Stack](https://www.elastic.co/guide/index.html)

---

## 📝 License

MIT
