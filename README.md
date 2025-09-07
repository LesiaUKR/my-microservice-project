
# Django CI/CD with Jenkins + Terraform + Helm + Argo CD

This repository implements a full GitOps-driven CI/CD for a Django application on AWS EKS using **Jenkins**, **Kaniko**, **Amazon ECR**, **Helm**, **Argo CD**, and **Terraform**.

## Navigation

[Back to Main Project](https://github.com/LesiaUKR/my-microservice-project/tree/main) - Main project overview and navigation to all lessons

## Tech stack
Terraform · AWS (EKS, ECR, ELB) · Kubernetes · Helm · Argo CD · Jenkins (Kubernetes agents + Kaniko) · PostgreSQL

---

## Architecture & Flow

1. **Developer pushes code** to GitHub.
2. **Jenkins** (Pipeline from SCM) spins up a **Kubernetes agent** with containers `kaniko` and `git`.
3. Jenkins **builds and pushes** the Docker image to **Amazon ECR** (tags: `v1.0.<BUILD_NUMBER>` and `latest`).
4. Jenkins **updates the Helm chart** `values.yaml` (image tag) in the **chart branch** and pushes the commit to GitHub.
5. **Argo CD** watches the chart branch and **auto‑syncs** the cluster.
6. **Kubernetes** rolls out a new Deployment; Service of type **LoadBalancer** exposes the app.

---

## Repository & Branch Layout

> The project uses separate branches for app code, chart, and infra/pipeline.

* **`lesson-4/`** — Django app code and Dockerfile

  * `django-docker-project/`

    * `Dockerfile`, `docker-entrypoint.sh`, `requirements.txt`, `django_app/`, `nginx/`, etc.
* **`lesson-7/`** — Helm chart tracked by Argo CD

  * **Chart path**: `lesson-5/charts/django-app/`

    * `templates/` (`deployment.yaml`, `service.yaml`, etc.)
    * `values.yaml` (holds `image.repository` and `image.tag`)
* **`lesson-8-9/`** — IaC + pipeline

  * `modules/` (S3+DynamoDB backend, VPC, ECR, EKS, Jenkins, Argo CD)
  * **`Jenkinsfile`** (the pipeline you run)

**Image repository**: `065915236794.dkr.ecr.us-west-2.amazonaws.com/lesson-9-django-ecr`

**Namespaces**: `jenkins`, `django-app`

---

## Prerequisites

* AWS account & CLI configured (`us-west-2` region)
* Terraform ≥ 1.5, kubectl, Helm
* GitHub Personal Access Token (PAT) with `repo` scope
* Docker (optional for local test builds)

---

## Provisioning with Terraform

From the infra root:

```bash
cd lesson-8-9
terraform init
terraform apply -auto-approve
```

Expected outcomes:

* EKS cluster with `django-app` namespace and PostgreSQL
* ECR repo `lesson-9-django-ecr`
* Jenkins (namespace `jenkins`) reachable via ELB
* Argo CD reachable via ELB; an `Application` pointing to the chart branch/path

> If Terraform outputs the Jenkins/Argo endpoints and passwords, keep them for the next steps.

---

## Jenkins Setup

1. **Credentials** → Global:

   * `aws-creds` — *AWS Credentials* (Access key + Secret key)
   * `github-token` — *Username with password* (GitHub login + PAT)
2. **Pipeline job**:

   * *Definition*: Pipeline script from SCM
   * *Repository*: `https://github.com/LesiaUKR/my-microservice-project.git`
   * *Branch*: `lesson-8-9`
   * *Script Path*: `lesson-8-9/Jenkinsfile`
   * **Disable** *Lightweight checkout*

### Jenkinsfile (high‑level)

* Checks out app code from **`lesson-4`** into `app-src/`
* Builds and pushes image to ECR via **Kaniko**, binding `aws-creds` to env vars
* Updates `values.yaml` in **`lesson-7/lesson-5/charts/django-app`** with the new tag
* Commits and pushes back to GitHub

Tags pushed to ECR: `v1.0.<BUILD_NUMBER>` and `latest`.

---

## Argo CD

* Watches **branch** `lesson-7`, **path** `lesson-5/charts/django-app`
* Auto‑sync enabled (recommended). Manual **SYNC** works too.
* After Jenkins pushes a new tag commit to `lesson-7`, Argo CD reconciles and rolls out the Deployment.

---

## How to Run the Pipeline

1. Open Jenkins → job → **Build Now**
2. Watch stages in Blue Ocean: *Checkout app code* → *Build & Push Docker Image* → *Update Chart Tag in Git*
3. Confirm new image in ECR and rollout in the cluster (see verification below).

---

## Verification

### Kubernetes

```bash
# pods and services
kubectl get pods -n django-app
kubectl get svc -n django-app

# image currently used by the deployment
kubectl get deploy django-app -n django-app \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

# rollout status
kubectl rollout status deploy django-app -n django-app
```

### External URL

```text
http://<your-elb-dns-name>
```

You should see the JSON message from the Django app (e.g., *Successfully deployed Django application with Docker!*).

### Amazon ECR

```bash
aws ecr describe-images \
  --repository-name lesson-9-django-ecr \
  --region us-west-2 \
  --query 'reverse(sort_by(imageDetails,&imagePushedAt))[:5].[imageTags,imagePushedAt]' \
  --output table
```

Expect to see `v1.0.<BUILD_NUMBER>` and `latest` among the tags.

### Argo CD

* Application should be **Healthy** and **Synced**.
* History should show a fresh sync after the Jenkins commit.

---

## Clean‑up

To avoid cloud charges when done:

```bash
cd lesson-8-9
terraform destroy -auto-approve
```

> If you also created the S3/DynamoDB backend via Terraform, destroy that module too, but only **after** the main stack is gone.

---

## Troubleshooting

* **ImagePullBackOff / ErrImagePull**: make sure ECR has an image tag used by the chart (`values.yaml`).
* **CrashLoopBackOff**: check Django env vars, DB connectivity, and container command.
* **Kaniko cannot push** (`no basic auth credentials`): ensure `aws-creds` is set and bound in the Jenkinsfile; region is `us-west-2`.
* **Argo OutOfSync**: press **SYNC** or verify the Application points to branch `lesson-7` and the correct chart path.
* **Kubernetes agent pod fails**: `serviceAccountName` must exist in `jenkins` namespace (e.g., `jenkins` or `default`).

---

## CI/CD in one picture (text)

`Jenkins (lesson-8-9/Jenkinsfile)` → **builds** app from `lesson-4` → **pushes** to `ECR` → **updates** Helm chart in `lesson-7` → `Argo CD` **syncs** → `EKS` **rolls out** → **ELB** serves Django.
