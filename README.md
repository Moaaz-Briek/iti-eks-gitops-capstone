# DevOps - Final Hands-On Project: Full GitOps Pipeline on AWS

## Capstone Project: Full GitOps Pipeline on AWS with Terraform, and Secrets Management

This capstone project focuses on provisioning and deploying a secure and production-ready infrastructure and CI/CD pipeline using Terraform, Amazon EKS, and modern DevOps tooling. The project integrates Jenkins, ArgoCD, Argo Image Updater, External Secrets Operator, and **GitHub Actions** to deploy a Node.js web application with MySQL and Redis on AWS.

## 🎯 Objective

The primary objective of this project is to demonstrate a comprehensive understanding of DevOps principles by building a robust and automated GitOps pipeline on AWS. This includes:

  * **Infrastructure as Code (IaC):** Provisioning all AWS resources using Terraform.
  * **Continuous Integration (CI):** Automating the build and push of Docker images using **GitHub Actions** and Jenkins.
  * **Continuous Delivery/Deployment (CD):** Implementing GitOps for application deployment with ArgoCD and automated image updates with Argo Image Updater.
  * **Secrets Management:** Securely managing application secrets using AWS Secrets Manager and External Secrets Operator.
  * **Application Deployment:** Deploying a multi-service Node.js application (web app, MySQL, Redis) on Kubernetes.
  * **Ingress and HTTPS:** Exposing the application securely with Ingress and HTTPS.

-----

## 📦 Project Scope

The project is structured into several key components, with Kubernetes manifests primarily managed via Helm charts and Kustomize for streamlined deployment through ArgoCD.

### ✅ 1. Infrastructure Provisioning – With Terraform

All AWS infrastructure is provisioned exclusively using Terraform.

  * **VPC Configuration:**
      * A Virtual Private Cloud (VPC) with 3 public and 3 private subnets spread across 3 Availability Zones (AZs).
      * NAT Gateway for outbound internet access from private subnets.
      * Internet Gateway for public subnet internet access.
      * Appropriate Route Tables configured for network flow.
  * **Amazon EKS Cluster:**
      * An Amazon EKS Control Plane.
      * Node groups deployed within private subnets for enhanced security.

-----

### ⚙ 2. CI Tool – Jenkins

Jenkins is utilized as a Continuous Integration tool to automate the build process, complementing GitHub Actions.

  * **Jenkins Installation:**
      * Jenkins is installed into the EKS cluster via Helm.
  * **Jenkins Pipelines:**
      * Pipelines are configured to:
          * Clone the Node.js application repository.
          * Build Docker images for the application.
          * Push the built Docker images to Amazon ECR.
          * Run the Terraform code for infrastructure changes.

-----

### 🔐 4. Secrets Management – External Secrets Operator

For secure handling of sensitive information, External Secrets Operator is integrated.

  * **Installation:**
      * External Secrets Operator is installed via Helm.
  * **Integration:**
      * Connects to AWS Secrets Manager to retrieve secrets.
      * Automatically synchronizes secrets from AWS Secrets Manager into Kubernetes Secrets, specifically for:
          * Database credentials (MySQL).
          * Redis credentials.

-----

### 🐍 5. Application: NodeJS App with MySQL and Redis

The project deploys a full-stack Node.js application.

  * **Node.js Web Application:**
      * Deploys the application from `https://github.com/mahmoud254/jenkins_nodejs_example.git`.
  * **Database and Caching:**
      * MySQL is deployed as a pod within the EKS cluster.
      * Redis is deployed as a pod within the EKS cluster for caching.
  * **Connectivity:**
      * The Node.js application connects to the MySQL pod using environment variables for configuration.
      * The Node.js application connects to the Redis pod for caching purposes.
  * **Kubernetes Manifests:**
      * Kubernetes manifests are managed using **Helm** (as seen in `cd/backend`, `cd/frontend`, `cd/mysql`, `cd/redis`) and **Kustomize** (for monitoring components in `cd/monitoring`).

-----

### 🌐 6. Ingress and HTTPS

The application is exposed securely to the internet.

  * **Ingress Controller:**
      * Deploys either NGINX Ingress Controller or AWS Load Balancer Controller.
  * **Ingress Resources:**
      * Utilizes Ingress resources to securely expose the Node.js application. The `cd/ingress` Helm chart defines the main Ingress resource (`app-ingress`) that routes traffic to the backend and frontend services.
  * **HTTPS:**
      * Integrates `cert-manager` and `Let's Encrypt` to automate the provisioning and renewal of HTTPS certificates. The `app.danielfarag.cloud` host defined in the Ingress uses `letsencrypt` as the `clusterIssuer`.


-----

## 📁 Project Structure

The repository is organized as follows:

```
.
├── .github                                 # GitHub Actions workflows for CI/CD automation
│   └── workflows
│       ├── build-backend-images.yaml       # Workflow to build and push backend Docker images
│       ├── build-frontend-images.yaml      # Workflow to build and push frontend Docker images
│       ├── terraform-apply-destroy-infra.yaml # Workflow to manage core AWS infrastructure with Terraform
│       ├── terraform-apply-destroy-manifests.yaml # Workflow to manage Kubernetes manifests with Terraform via Bastion
│       └── terraform-apply-destroy-platform.yaml # Workflow to manage platform components with Terraform via Bastion
├── backend                                 # Node.js backend application source code
├── cd                                      # Continuous Delivery (ArgoCD) configurations and Helm charts
│   ├── backend                             # Helm chart for backend application
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   └── values.yaml
│   ├── frontend                            # Helm chart for frontend application
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   └── values.yaml
│   ├── ingress                             # Helm chart for Ingress
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   └── values.yaml
│   ├── monitoring                          # Kustomize/manifests for monitoring components (e.g., Prometheus)
│   │   ├── alertmanager-config.yaml
│   │   ├── grafana-dashboard.yaml
│   │   ├── kustomization.yaml
│   │   ├── prometheus-backend-servicemonitor.yaml
│   │   ├── prometheus-backend-service.yaml
│   │   └── prometheus-rule.yaml
│   ├── mysql                               # Helm chart for MySQL
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   └── values.yaml
│   ├── README.md
│   └── redis                               # Helm chart for Redis
│       ├── Chart.yaml
│       ├── templates
│       └── values.yaml
├── frontend                                # Angular frontend application source code
├── Makefile                                # Makefile for common commands (e.g., `terraform apply`)
├── README.md                               # This README file
├── terraform                               # Terraform configurations for AWS infrastructure and Kubernetes manifests
│   ├── infra                               # Core AWS infrastructure (VPC, EKS cluster)
│   │   ├── backend.tf
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── modules                         # Reusable Terraform modules
│   │   │   ├── bastion
│   │   │   ├── ecr
│   │   │   ├── eks
│   │   │   ├── secrets
│   │   │   └── vpc
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   ├── README.md
│   │   ├── variables.tf
│   │   └── vars.tfvars
│   ├── manifests                           # Terraform for deploying Kubernetes manifests (e.g., External Secrets Operator)
│   │   ├── backend.tf
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── providers.tf
│   │   ├── README.md
│   │   ├── secrets                         # Templates for External Secrets Operator configurations
│   │   ├── secrets.tf
│   │   ├── variables.tf
│   │   └── vars.tfvars
│   └── platform                            # Terraform for platform-level deployments (Jenkins, ArgoCD, Ingress)
│       ├── backend.tf
│       ├── data.tf
│       ├── ingress-controller              # Terraform for Ingress Controller
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   ├── Scripts
│       │   └── variables.tf
│       ├── main.tf
│       ├── manifests
│       │   └── storage-class.yaml
│       ├── output.tf
│       ├── providers.tf
│       ├── README.md
│       ├── route53                         # Terraform for Route 53 (DNS)
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── service_accounts.tf
│       ├── storage.tf
│       ├── values                          # Helm values files for platform components
│       │   ├── argocd-values.yaml
│       │   ├── certbot-values.yaml
│       │   ├── image-updater-values.yaml
│       │   ├── jenkins-values.yaml
│       │   └── monitoring-values.yaml
│       ├── variables.tf
│       └── vars.tfvars
```

## 🚀 Getting Started

To get this project up and running, follow these general steps. More detailed instructions will be available in the respective subdirectories (e.g. [GitHub Workflows](.github/workflows/README.md), [Continuous Deployment (CD)](cd/README.md),  [Terraform Infrastructure](terraform/infra/README.md)).

### Prerequisites

  * AWS Account with programmatic access configured.
  * Terraform installed.
  * `kubectl` installed and configured
  * Helm installed.
  * AWS CLI installed and configured.
  * **GitHub Repository:** Ensure you have a GitHub repository set up with necessary [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AUTH_TOKEN`) and [GitHub Variables](https://docs.github.com/en/actions/learn-github-actions/variables) (`AWS_REGION`, `INSTANCE_TYPE`, `BUCKET_NAME`, `CLUSTER_NAME`) configured for GitHub Actions.

### Deployment Steps

1.  **Configure AWS Credentials:** Ensure your AWS CLI is configured with the necessary permissions.
2.  **Terraform Infrastructure (VPC, EKS):**
      * Trigger the **`Terraform Apply/Destroy - Infra` GitHub Actions workflow** with the `apply` action. This will provision your core AWS infrastructure, including the VPC and EKS cluster.
3.  **Deploy Platform Tools (Jenkins, ArgoCD, etc.):**
      * Trigger the **`Terraform Apply/Destroy - Platform` GitHub Actions workflow** with the `apply` action. This will deploy essential platform components like Jenkins, ArgoCD, Argo Image Updater, External Secrets Operator, and the Ingress Controller onto your EKS cluster via the Bastion host.
4.  **Deploy Kubernetes Manifests (Secrets Operator, etc.):**
      * Trigger the **`Terraform Apply/Destroy - Manifests` GitHub Actions workflow** with the `apply` action. This step handles the deployment of Kubernetes manifests, such as the External Secrets Operator setup, through the Bastion host.
5.  **Build and Push Docker Images:**
      * Manually trigger the **`Build Backend Images` GitHub Actions workflow**. This will build your backend Node.js application's Docker image and push it to Amazon ECR.
      * Manually trigger the **`Build Frontend Images` GitHub Actions workflow**. This will build your frontend Angular application's Docker image and push it to Amazon ECR.
      * *(Alternatively, if Jenkins is fully configured, it can handle these builds and pushes directly within the cluster, providing a flexible CI approach.)*
6.  **Configure Jenkins:**
      * Access the Jenkins UI (retrieve service endpoint from EKS).
      * Set up the Jenkins pipeline(s) to build and push Docker images to ECR (if not relying solely on GitHub Actions for this) and to trigger any necessary Terraform operations. The `Jenkinsfile` in `backend/` and `frontend/` provide the pipeline definitions.
7.  **Configure ArgoCD:**
      * Access the ArgoCD UI (retrieve service endpoint from EKS).
      * Add your Git repository as a source.
      * Create `Application` resources in ArgoCD pointing to the Helm charts in the `cd/` directory for the backend, frontend, MySQL, and Redis.
      * Ensure Argo Image Updater is configured to monitor your ECR repositories and update the Git repository accordingly.
8.  **Deploy Application:**
      * With ArgoCD configured, the application (backend, frontend, MySQL, Redis) should automatically deploy to the EKS cluster based on the Git repository state and any new image tags detected by Argo Image Updater.
9.  **Secrets Management:**
      * Ensure your secrets are configured in AWS Secrets Manager.
      * Verify that External Secrets Operator is syncing these secrets into Kubernetes.
10. **Ingress and HTTPS :**
      * ensure the Ingress controller is active and `cert-manager` is configured to provision certificates for your domain.

## Usage

Once deployed, the Node.js application will be accessible via the Ingress endpoin. You can interact with the web application, which will connect to the MySQL database and utilize Redis for caching. Monitoring dashboards and alerts will also be active via Prometheus and Grafana.
