# My Microservice Project

Complete DevOps learning project with practical assignments and hands-on implementations.

## Project Overview

This repository contains homework assignments and practical projects for a DevOps engineering course. Each lesson is organized in separate branches to maintain clean project structure and version control best practices.

## Course Structure

### Completed Lessons

- [**Lesson 3: Linux Administration**](https://github.com/LesiaUKR/my-microservice-project/tree/lesson-3) - DevOps Tools Installation Script
  - Automated Bash script for installing Docker, Docker Compose, Python, and Django
  - Features error handling, version checking, and colored output
  - Compatible with Ubuntu/Debian systems
- [**Lesson 4: Docker Containerization**](https://github.com/LesiaUKR/my-microservice-project/tree/lesson-4) - Django + PostgreSQL + Nginx
  - Multi-container Docker application with Django web framework
  - PostgreSQL database integration with persistent data volumes
  - Nginx reverse proxy for production-ready deployment
  - Docker Compose orchestration for seamless service management
- [**Lesson 5: Terraform Infrastructure as Code**](https://github.com/LesiaUKR/my-microservice-project/tree/lesson-5) - AWS Infrastructure with Terraform
  - S3 backend for remote state storage with versioning and encryption
  - DynamoDB table for state locking and team collaboration
  - VPC with multi-AZ architecture, public/private subnets, NAT Gateways
  - ECR repository for container image storage with security scanning

## Repository Structure

```
my-microservice-project/
├── main branch          # Project overview and navigation
├── lesson-3 branch      # Linux Administration & DevOps Tools
└── lesson-4 branch      # Docker Containerization
```

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/LesiaUKR/my-microservice-project.git
cd my-microservice-project
```

2. Switch to specific lesson branch:
```bash
git checkout lesson-3  # For Linux Administration lesson
```

3. Follow the README instructions in each branch