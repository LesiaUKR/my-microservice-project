# Infrastructure Project on Terraform and Kubernetes (EKS)

## Executive Summary
This project demonstrates the deployment of a **Django application** in AWS EKS using a full DevOps toolchain.  
It includes:  
- Infrastructure provisioning with Terraform  
- CI/CD automation with Jenkins  
- GitOps synchronization with ArgoCD  
- Autoscaling with Horizontal Pod Autoscaler (HPA)  
- Monitoring with Prometheus & Grafana  

The workflow covers the entire lifecycle: code commit → build & push Docker image → Helm chart update → ArgoCD sync → Kubernetes deployment → monitoring and autoscaling.

---

## Navigation
[Back to Main Project](https://github.com/LesiaUKR/my-microservice-project/tree/main) - Main project overview and navigation to all lessons

## Table of Contents
- [Executive Summary](#executive-summary)
- [Navigation](#navigation)
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Modules](#modules)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Using Terraform](#using-terraform)
- [Deploy Django Application with Helm](#deploy-django-application-with-helm)
- [Jenkins CI/CD Module](#jenkins-cicd-module)
- [ArgoCD Module](#argocd-module)
- [RDS Module](#rds-module)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Validation & Results](#validation--results)


---

## Project Overview
This project automates the deployment of AWS infrastructure for a microservices-based Django application using Terraform, Helm, and Kubernetes (EKS).  
It includes:  
- CI/CD with Jenkins  
- Deployment of Django application with Helm  
- Remote state storage in S3 with DynamoDB locking  
- Horizontal Pod Autoscaler (HPA) for autoscaling  

---

## Architecture
```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│   VPC    │  │   ECR    │  │   S3     │  │   EKS   │  │  Jenkins │  │  Argo CD │  │   RDS    │
│  Module  │  │  Module  │  │ Backend  │  │ Module  │  │  Module  │  │  Module  │  │  Module  │
└──────────┘  └──────────┘  └──────────┘  └─────────┘  └──────────┘  └──────────┘  └──────────┘
```

- VPC: Private/public subnets, NAT, IGW  
- ECR: Docker repository for images  
- S3/DynamoDB: Backend for Terraform state  
- EKS: Kubernetes cluster for Django + Jenkins  
- Jenkins: CI/CD pipelines, seed-job, GitHub integration  
- ArgoCD: GitOps sync with Helm charts, automated app updates  
- RDS: PostgreSQL or Aurora database  

---

## Modules
- **VPC (modules/vpc):** Creates VPC, subnets, routing, NAT/IGW  
- **ECR (modules/ecr):** Creates ECR repository for Docker images  
- **S3-backend (modules/s3-backend):** S3 bucket + DynamoDB for Terraform state  
- **EKS (modules/eks):** EKS cluster, node group, IAM roles  
- **Jenkins (modules/jenkins):** Deploys Jenkins via Helm, seed-job, PVC  
- **Django Helm Chart (charts/django-app):** Deploys Django app with HPA  

---

## Prerequisites
- AWS account with admin privileges  
- Terraform 1.0+  
- AWS CLI  
- kubectl  
- Helm  
- Docker (for image builds)  

---

## Installation & Setup
Clone the repository:
```bash
git clone <repo-url>
cd final-project
```

Configure AWS CLI:
```bash
aws configure
```

Initialize Terraform:
```bash
terraform init
```

---

## Using Terraform
View plan:
```bash
terraform plan
```

Apply:
```bash
terraform apply
```

Destroy:
```bash
terraform destroy
```

---

## Deploy Django Application with Helm
Build and push Docker image:
```bash
docker build --platform linux/amd64 -t <ecr-repo>:<tag> .
docker push <ecr-repo>:<tag>
```

Update `charts/django-app/values.yaml` with your image.  

Deploy with Helm:
```bash
helm upgrade --install django-app ./charts/django-app
```

Get EXTERNAL-IP:
```bash
kubectl get svc -n django-app
```

Open in browser (port 80).  

HPA scaling:  
- Min pods: 2  
- Max pods: 6  
- CPU target: 70% (tested also with 30% under load)  

---

## Jenkins CI/CD Module
- Deployed via Terraform (Helm chart).  
- Storage: PVC backed by EBS (gp2 or ebs-sc).  
- Seed-job: Creates pipeline from GitHub repo (Job DSL).  
- GitHub PAT stored securely in Jenkins Credentials.  

Access Jenkins:
```bash
kubectl get svc -n jenkins
```
Open `EXTERNAL-IP:8080` in browser.  

Steps:  
1. Login to Jenkins.  
2. Run the seed-job → creates pipeline `django-app-pipeline`.  
3. Pipeline stages:  
   - Build & push Docker image to ECR  
   - Commit updated `values.yaml` (image.tag)  
   - ArgoCD syncs and updates deployment  

---

## ArgoCD Module
Deployed via Terraform using Helm.  

Access:
```bash
kubectl get svc -n argocd
```
Open `EXTERNAL-IP:8080` in browser.  

Login:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

App must show **Healthy** & **Synced** in ArgoCD Dashboard.  

---

## RDS Module
- Deployed via Terraform (Postgres RDS or Aurora).  

Connection example:
```bash
psql --host=mydb.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com      --port=5432      --username=mydbuser      --dbname=mydatabase
```

---

## Security
- Use IAM roles instead of access keys  
- Encrypt Terraform state in S3  
- Do not store secrets in plain text  
- Store GitHub PAT in Jenkins Credentials  
- Monitor logs and resources  

---

## Troubleshooting
- PVC Pending → Check StorageClass and AWS permissions  
- Jenkins not starting → Check pod logs, PVC, resources  
- LoadBalancer no EXTERNAL-IP → Wait or check cloud provider  
- kubectl not connecting → Update kubeconfig via AWS CLI  
- Helm release failed → Remove old release  
```bash
helm uninstall <release-name> -n <namespace>
```

---

## Validation & Results
- Jenkins pipeline completed successfully (build → push → update chart).  
- ArgoCD shows application status as Healthy & Synced.  
- HPA scaled replicas up under load and back down after.  
- Grafana dashboards confirmed CPU/memory usage and autoscaling events.  

---

## License
This project was created for educational purposes.

---

