# Architecture & Data Flow Diagrams

## 📐 Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     AWS Region (us-east-1)                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                     │  │
│  │                                                          │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │  Availability Zone (us-east-1a)                   │ │  │
│  │  │                                                    │ │  │
│  │  │  ┌──────────────────────────────────────────────┐ │ │  │
│  │  │  │  Public Subnet (10.0.1.0/24)                 │ │ │  │
│  │  │  │                                              │ │ │  │
│  │  │  │  ┌────────────────────────────────────────┐ │ │ │  │
│  │  │  │  │     EC2 Instance (t2.micro)           │ │ │ │  │
│  │  │  │  │                                        │ │ │ │  │
│  │  │  │  │  Port 80:     App (Flask on 5000)     │ │ │ │  │
│  │  │  │  │  Port 3000:   Grafana                 │ │ │ │  │
│  │  │  │  │  Port 9090:   Prometheus              │ │ │ │  │
│  │  │  │  │  Port 9200:   Elasticsearch           │ │ │ │  │
│  │  │  │  │  Port 5601:   Kibana                  │ │ │ │  │
│  │  │  │  │                                        │ │ │ │  │
│  │  │  │  │  IAM Role: CloudWatch Agent            │ │ │ │  │
│  │  │  │  └────────────────────────────────────────┘ │ │ │  │
│  │  │  │                                              │ │ │  │
│  │  │  └──────────────────────────────────────────────┘ │ │  │
│  │  │                                                    │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  │                                                          │  │
│  │  ┌──────────────┐                                        │  │
│  │  │ Internet GW  │                                        │  │
│  │  └──────────────┘                                        │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CloudWatch (Central Monitoring)                          │  │
│  │  ├─ Log Group: /aws/ec2/hello-devops                     │  │
│  │  ├─ Metrics: CPU, Memory, Disk, Status                  │  │
│  │  ├─ Dashboard: 6 widgets                                 │  │
│  │  └─ Alarms: CPU, Memory, Disk, Status (→ SNS → Email)   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  S3 & DynamoDB (Terraform State Management)              │  │
│  │  ├─ S3: Encrypted state files with versioning           │  │
│  │  └─ DynamoDB: State locking (prevents conflicts)        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow: Metrics & Logs

```
EC2 Instance (CloudWatch Agent)
    ├─ System Metrics (every 60s)
    │   ├─ CPU Utilization → CloudWatch
    │   ├─ Memory Utilization → CloudWatch
    │   ├─ Disk Utilization → CloudWatch
    │   └─ Status Checks → CloudWatch
    │
    └─ Application Logs (real-time)
        ├─ /var/log/cloud-init-output.log → CloudWatch Logs
        ├─ /var/log/docker → CloudWatch Logs
        └─ Docker app logs → Logstash → Elasticsearch → Kibana
```

---

## 🚀 CI/CD Pipeline Flow

```
Developer pushes code to main
    ↓
GitHub Actions triggered
    ├─ Job: TEST (always runs)
    │  ├─ Checkout code
    │  ├─ Install dependencies
    │  ├─ Run pytest tests
    │  └─ If any test fails → STOP, notify developer
    │
    ├─ Job: BUILD (only if test passed)
    │  ├─ Login to Docker Hub
    │  ├─ Build Docker image
    │  ├─ Push with tags:
    │  │  ├─ latest
    │  │  └─ <commit-sha>
    │  └─ If push fails → STOP, notify developer
    │
    └─ Job: DEPLOY (only if build succeeded)
       ├─ SSH into EC2
       ├─ Pull latest Docker image
       ├─ Stop old container
       └─ Start new container
       
Result: New version live on EC2 (2-3 min total)
```

---

## 🔐 Security Model

```
External (Internet)
    ↓ (Traffic)
    ├─ SSH (Port 22): From your IP only ✓
    ├─ HTTP (Port 80): From anywhere (app needs this)
    └─ App (Port 5000): From anywhere (public service)
    
Internal (VPC 10.0.0.0/16)
    ├─ Grafana (3000): Only from your IP ✓
    ├─ Prometheus (9090): Only from your IP ✓
    ├─ Kibana (5601): Only from your IP ✓
    └─ Elasticsearch (9200): Internal only ✓

AWS Services
    ├─ CloudWatch: EC2 sends metrics (IAM limited)
    ├─ CloudWatch Logs: EC2 sends logs (IAM limited)
    └─ SNS: Sends alerts (IAM limited to specific log group)

GitHub
    ├─ Secrets stored securely
    └─ SSH keys never exposed
```

---

## 📊 Monitoring Stack Integration

```
Application (Flask)
    ↓
Container Logs (/var/log/docker)
    ├─ → CloudWatch (AWS)
    │   ├─ Stored for 7 days
    │   └─ Visible in CloudWatch Logs console
    │
    └─ → Logstash (Docker)
        ├─ Processes logs
        ├─ Adds timestamps/tags
        └─ Forwards to Elasticsearch
            ↓
        Elasticsearch (Docker)
        ├─ Stores indexed logs
        └─ Enables full-text search
            ↓
        Kibana (Port 5601)
        ├─ Beautiful dashboards
        ├─ Log queries
        └─ Trend analysis

System Metrics
    ├─ CloudWatch Agent (running on EC2)
    │   ├─ Collects: CPU, Memory, Disk, Network
    │   └─ Sends to CloudWatch (namespace: HelloDevOps/EC2)
    │
    ├─ CloudWatch Dashboard
    │   ├─ 6 widgets with real-time graphs
    │   └─ Historical data for trend analysis
    │
    ├─ Prometheus (Port 9090)
    │   ├─ Scrapes metrics
    │   └─ Time-series storage
    │
    └─ Grafana (Port 3000)
        ├─ Visualizes Prometheus metrics
        └─ Pretty dashboards
```

---

## 🚨 Alert Flow

```
EC2 Metrics exceed threshold
    ↓
CloudWatch detects alarm condition
    ↓
Alarm publishes to SNS Topic
    ├─ Alert triggered:
    │  ├─ CPU > 80%
    │  ├─ Memory > 80%
    │  ├─ Disk > 80%
    │  └─ Status Check Failed
    ↓
SNS distributes to subscribers
    ↓
Email sent to your alert_email address
    ↓
You receive email with alarm details
    ├─ Alarm name
    ├─ Current value
    ├─ Threshold
    └─ Time triggered
    ↓
You SSH into EC2 to investigate
    ├─ Check docker logs
    ├─ Check system metrics
    └─ Take action (scale, restart, etc)
```

---

## 🔄 State Management Architecture

```
Your Local Machine
    └─ terraform/ (code you write)
        ├─ main.tf, instance.tf, etc.
        └─ terraform apply/plan commands
        
        ↓ (State file)
        
AWS Account
    └─ S3 Bucket (hello-devops-terraform-state-mali)
        ├─ terraform.tfstate (current state)
        ├─ terraform.tfstate.backup (previous state)
        └─ All previous versions (versioning enabled)
    
    + DynamoDB Table (terraform-state-lock)
        ├─ Locks state during apply
        └─ Prevents concurrent changes

Benefits:
✓ Team can share infrastructure state
✓ Can't accidentally overwrite changes
✓ Complete history of all infrastructure changes
✓ Encrypted at rest
```

---

## 🎯 How Everything Connects

```
GitHub Repository
├─ Code + Terraform
│  └─ Triggers → GitHub Actions
│
GitHub Actions (CI/CD)
├─ Tests code
├─ Builds Docker image
└─ Deploys to EC2 via SSH
    └─ Uses EC2_SSH_KEY secret
    
EC2 Instance (AWS)
├─ Runs application
├─ Runs monitoring stack
└─ Sends metrics/logs to CloudWatch
    └─ Uses IAM role (least-privilege)
    
CloudWatch (AWS Monitoring)
├─ Collects metrics
├─ Aggregates logs
├─ Displays dashboard
└─ Triggers alarms
    └─ Sends to SNS
    
SNS Topic
├─ Receives alarms
└─ Sends emails
    └─ You receive notifications
    
Prometheus/Grafana/ELK (On EC2)
├─ Alternative dashboards
├─ Log analysis
└─ Custom visualizations
    └─ Access via EC2 IP:port
```

---

## 📈 Scaling Considerations (For Future)

If you wanted to scale this (not for $1 budget):

```
Current (Single EC2):
├─ Application + Monitoring stack on one instance
└─ Cost: ~$0.90/month

Scale Option 1 (High Availability):
├─ Multi-AZ EC2 instances
├─ Load balancer distributes traffic
├─ Separate monitoring instance
└─ Cost: ~$3-5/month

Scale Option 2 (ECS/Fargate):
├─ Docker containers managed by ECS
├─ Auto-scaling based on load
├─ Managed logging
└─ Cost: Pay per task/hour

Scale Option 3 (Kubernetes - EKS):
├─ Full container orchestration
├─ Advanced networking
├─ Helm charts for monitoring
└─ Cost: ~$10+/month
```

For now, stick with Single EC2 ✓
