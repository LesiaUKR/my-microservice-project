# Kubernetes EKS Deployment with Helm

AWS EKS cluster deployment with Django application using Terraform and Helm charts for automated scaling and container orchestration.

## Navigation

[Back to Main Project](https://github.com/LesiaUKR/my-microservice-project/tree/main) - Main project overview and navigation to all lessons


## Project Overview

This project demonstrates production-ready Kubernetes deployment on AWS EKS with:

- **EKS Cluster** - Managed Kubernetes cluster with worker nodes
- **ECR Integration** - Container registry for Django application images
- **Helm Charts** - Kubernetes package manager for application deployment
- **Auto-scaling** - Horizontal Pod Autoscaler (HPA) for dynamic scaling
- **Load Balancer** - External access via AWS LoadBalancer service

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS EKS Cluster                          │
├─────────────────────────────────────────────────────────────────┤
│  LoadBalancer Service                                           │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ External IP: ae00c575d1e754a6092cd3a33269251d-793710141...  ││
│  └─────────────────────────────────────────────────────────────┘│
│                              │                                  │
│  ┌───────────────────────────▼─────────────────────────────────┐│
│  │              Kubernetes Services                            ││
│  │  ┌─────────────────┐  ┌─────────────────┐                   ││
│  │  │ Django App Pods │  │ PostgreSQL Pod  │                   ││
│  │  │ (Min: 2)        │  │                 │                   ││
│  │  │ (Max: 6)        │  │                 │                   ││
│  │  │ CPU: 70% HPA    │  │                 │                   ││
│  │  └─────────────────┘  └─────────────────┘                   ││
│  └─────────────────────────────────────────────────────────────┘│
│                              │                                  │
│  ┌───────────────────────────▼─────────────────────────────────┐│
│  │                   ConfigMap                                 ││
│  │  Environment Variables from Lesson 4                        ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
lesson-5/
├── main.tf                     # Main Terraform configuration
├── backend.tf                  # S3 remote state configuration
├── outputs.tf                  # Infrastructure outputs
├── .gitignore                  # Terraform-specific ignores
├── .terraform.lock.hcl         # Terraform dependency lock file
├── terraform.tfstate           # Local state file (before remote migration)
├── terraform.tfstate.backup    # State backup file
├── README.md                   # Project documentation
│
├── modules/                    # Terraform modules
│   ├── s3-backend/            # S3 + DynamoDB for remote state
│   │   ├── s3.tf              # S3 bucket configuration
│   │   ├── dynamodb.tf        # DynamoDB table for locking
│   │   ├── variables.tf       # Input variables
│   │   └── outputs.tf         # Module outputs
│   │
│   ├── vpc/                   # VPC networking module
│   │   ├── vpc.tf             # VPC, subnets, gateways
│   │   ├── routes.tf          # Route tables and associations
│   │   ├── variables.tf       # Input variables
│   │   └── outputs.tf         # Module outputs
│   │
│   ├── ecr/                   # ECR repository module
│   │   ├── ecr.tf             # Container registry configuration
│   │   ├── variables.tf       # Input variables
│   │   └── outputs.tf         # Module outputs
│   │
│   └── eks/                   # EKS cluster module
│       ├── eks.tf             # EKS cluster and node group
│       ├── variables.tf       # Input variables
│       └── outputs.tf         # Module outputs
│
└── charts/                    # Helm charts
    └── django-app/            # Django application chart
        ├── Chart.yaml         # Chart metadata
        ├── values.yaml        # Default configuration values
        └── templates/         # Kubernetes templates
            ├── _helpers.tpl   # Template helpers
            ├── configmap.yaml # Environment configuration
            ├── deployment.yaml# Django deployment
            ├── hpa.yaml       # Horizontal Pod Autoscaler
            ├── postgres.yaml  # PostgreSQL deployment
            └── service.yaml   # LoadBalancer service
```

## Features

### EKS Cluster
- **Managed Control Plane**: AWS-managed Kubernetes API server
- **Worker Nodes**: Auto-scaling EC2 instances (t3.medium)
- **Multi-AZ Deployment**: High availability across availability zones
- **VPC Integration**: Deployed in existing VPC from previous lesson

### Helm Chart Components
- **Deployment**: Django application with resource limits and health checks
- **Service**: LoadBalancer for external access (port 80 → 8000)
- **ConfigMap**: Environment variables migrated from lesson 4
- **HPA**: Auto-scaling from 2 to 6 pods based on 70% CPU utilization
- **PostgreSQL**: Database deployment with persistent storage

### Container Registry
- **ECR Repository**: lesson-5-ecr with Django application image
- **Image Security**: Vulnerability scanning enabled
- **Automated Pulls**: EKS pulls images from ECR automatically

## Prerequisites

- **Terraform** >= 1.0 installed
- **AWS CLI** configured with EKS permissions
- **kubectl** installed and configured
- **Helm** >= 3.0 installed
- **Docker** for building and pushing images
- **Existing VPC** from lesson 5

## Deployment Instructions

### Phase 1: Infrastructure Deployment

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Deploy EKS cluster and ECR:**
```bash
terraform plan
terraform apply
```

3. **Configure kubectl:**
```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-5-eks-cluster
```

4. **Verify cluster access:**
```bash
kubectl get nodes
kubectl get namespaces
```

### Phase 2: Container Image Preparation

1. **Authenticate with ECR:**
```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com
```

2. **Tag and push Django image:**
```bash
docker tag lesson-5-django-app:latest <ecr-url>:latest
docker push <ecr-url>:latest
```

### Phase 3: Helm Deployment

1. **Navigate to chart directory:**
```bash
cd charts/django-app
```

2. **Validate Helm chart:**
```bash
helm lint .
helm template django-release . --debug
```

3. **Deploy application:**
```bash
helm install django-release .
```

4. **Verify deployment:**
```bash
helm list
kubectl get pods
kubectl get services
kubectl get hpa
```

## Application Access

The Django application is accessible via the LoadBalancer external URL:

```
http://ae00c575d1e754a6092cd3a33269251d-793710141.us-west-2.elb.amazonaws.com
```

**Response format:**
```json
{
  "title": "Django + Docker + PostgreSQL + Nginx",
  "message": "Successfully deployed Django application with Docker!"
}
```

## Configuration

### Helm Values (values.yaml)

```yaml
# Application image
image:
  repository: 065915236794.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr
  tag: latest
  pullPolicy: Always

# Service configuration
service:
  type: LoadBalancer
  port: 80
  targetPort: 8000

# Auto-scaling settings
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 6
  targetCPUUtilizationPercentage: 70

# Environment variables (placeholders pointed - use yours credentials)
config:
  DEBUG: "False"
  SECRET_KEY: "django-production-key-change-this"
  POSTGRES_DB: "myproject"
  POSTGRES_USER: "postgres"
  POSTGRES_PASSWORD: "postgres"
  DB_HOST: "postgres-service"
  DB_PORT: "5432"
```

### Resource Limits

```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

## Management Commands

### Terraform Commands
```bash
# View infrastructure
terraform show
terraform state list

# Update infrastructure
terraform plan
terraform apply

# Destroy infrastructure
terraform destroy
```

### Kubectl Commands
```bash
# Monitor pods
kubectl get pods -w
kubectl describe pods

# View logs
kubectl logs <pod-name>

# Scale manually (if HPA disabled)
kubectl scale deployment django-release-django-app --replicas=4

# Port forwarding (for testing)
kubectl port-forward svc/django-release-django-app 8080:80
```

### Helm Commands
```bash
# List releases
helm list

# Upgrade release
helm upgrade django-release .

# Rollback release
helm rollback django-release 1

# Uninstall release
helm uninstall django-release

# View release history
helm history django-release
```

## Monitoring and Scaling

### Horizontal Pod Autoscaler
The HPA automatically scales pods based on CPU utilization:
- **Target CPU**: 70%
- **Min Replicas**: 2
- **Max Replicas**: 6
- **Scale Up**: When average CPU > 70%
- **Scale Down**: When average CPU < 70%

### Health Checks
- **Liveness Probe**: HTTP GET to `/` every 10 seconds
- **Readiness Probe**: HTTP GET to `/` every 5 seconds
- **Initial Delay**: 30 seconds for liveness, 5 seconds for readiness

## Cost Optimization

- **EKS Cluster**: ~$72/month for control plane
- **Worker Nodes**: ~$30/month per t3.medium instance
- **LoadBalancer**: ~$18/month for Classic Load Balancer
- **ECR Storage**: First 500MB free, then $0.10/GB/month

## Security Features

- **Private Subnets**: Worker nodes in private subnets
- **Security Groups**: Controlled network access
- **IAM Roles**: Least privilege access for EKS components
- **Image Scanning**: ECR vulnerability scanning enabled
- **Resource Limits**: CPU and memory constraints prevent resource exhaustion

**Security Note**: Use Kubernetes Secrets for sensitive data in production instead of ConfigMaps.

## Troubleshooting

### Common Issues

1. **Pods stuck in Pending**: Check node capacity and resource requests
2. **LoadBalancer creation fails**: Verify VPC and subnet configuration
3. **Image pull failures**: Check ECR permissions and repository existence
4. **HPA not scaling**: Verify metrics-server is installed and CPU requests are set

### Diagnostic Commands

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes -o wide

# Debug pod issues
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous

# Check HPA metrics
kubectl describe hpa
kubectl top pods

# View events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Cleanup

To destroy all resources and avoid ongoing costs:

```bash
# Uninstall Helm release
helm uninstall django-release

# Destroy Terraform infrastructure
terraform destroy

# Clean up Docker images (optional)
docker image prune -a
```

## Next Steps

- Implement GitOps with ArgoCD
- Add monitoring with Prometheus and Grafana
- Configure ingress with cert-manager for TLS
- Implement backup strategies for PostgreSQL
- Set up centralized logging with ELK stack