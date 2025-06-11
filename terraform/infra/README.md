## Terraform Configuration Overview

Your Terraform setup is meticulously organized into three main directories: `infra`, `manifests`, and `platform`. Each directory serves a distinct purpose in provisioning and managing your AWS and Kubernetes resources.

### 1. `terraform/infra`

This directory is responsible for provisioning the foundational AWS infrastructure for your EKS cluster.

-   **Backend Configuration (`backend.tf`):**

    ```terraform
    terraform {
      backend "s3" {
        bucket  = "iti-graduation-730335506473"
        key = "terraform/state/infra"
        region = "us-east-1"
      }
    }
    ```
    This block configures Terraform to store its state file in an S3 bucket named `iti-graduation-730335506473` under the key `terraform/state/infra` in the `us-east-1` region. This is crucial for collaborative development and maintaining a reliable state.

    This block configures Terraform to store its state file in an S3 bucket named `iti-graduation-730335506473` under the key `terraform/state/infra` in the `us-east-1` region. This is crucial for collaborative development and maintaining a reliable state.

-   **Data Sources:**

    -   `data "aws_instances" "eks_nodes"`: This data source is used to filter and retrieve information about AWS instances that are tagged with the `eks:cluster-name` matching `var.cluster_name`. This allows you to reference existing EKS nodes if needed, though in the provided snippet it's not directly consumed by a resource.

-   **Module Invocations (Main Components):**

    -   **`module "vpc"`:**
        -   **Source:** `./modules/vpc` (a local module for VPC creation).
        -   **Purpose:** Provisions the core network infrastructure, including a VPC, public, and private subnets across 3 Availability Zones.
        -   **Inputs:** `vpc_cidr`, `public_subnet_cidrs`, `private_subnet_cidrs`, `az_count`, `cluster_name`.
    -   **`module "bastion"`:**
        -   **Source:** `./modules/bastion` (a local module for bastion host).
        -   **Purpose:** Deploys a bastion host, likely within a private subnet, to provide secure access to the private network.
        -   **Inputs:** `vpc_id`, `private_subnet_ids`, `cluster_name`, `private_subnet_cidrs`, `region`, `bucket`.
    -   **`module "eks"`:**
        -   **Source:** `./modules/eks` (a local module for EKS cluster).
        -   **Dependencies:** `depends_on = [ module.vpc, module.bastion]` ensures VPC and Bastion are created first.
        -   **Purpose:** Provisions the Amazon EKS control plane and node groups.
        -   **Inputs:** `cluster_name`, `vpc_id`, `private_subnet_ids`, `private_subnet_cidrs`, `node_instance_types`, `node_desired_capacity`, `node_min_capacity`, `node_max_capacity`, `region`, `s3_bucket` (for Jenkins/Kaniko, potentially), `s3_bucket_state` (for EKS state), `bastion_role_arn`.
    -   **`module "ecr"`:**
        -   **Source:** `./modules/ecr` (a local module for ECR).
        -   **Purpose:** Sets up Amazon Elastic Container Registry (ECR) repositories for your Docker images. It also likely configures IAM roles for EKS to pull images and for Jenkins/Kaniko to push images.
        -   **Inputs:** `cluster_name`, `region`, `eks_oidc_arn`, `eks_oidc_issuer`.
    -   **`module "secrets"`:**
        -   **Source:** `./modules/secrets` (a local module for secrets management).
        -   **Dependencies:** `depends_on = [ module.eks ]` ensures EKS is ready as it relies on EKS OIDC.
        -   **Purpose:** Likely sets up AWS Secrets Manager and potentially IAM roles necessary for the External Secrets Operator to retrieve secrets.
        -   **Inputs:** `eks_oidc_arn`, `cluster_name`.

-   **Outputs (`outputs.tf`):**

    -   `vpc_id`, `public_subnet_ids`, `private_subnet_ids`: Network identifiers.
    -   `eks_cluster_name`: Name of the EKS cluster.
    -   `bastion_id`: Instance ID of the bastion host.
    -   `ecr_url`, `ecr_token`: ECR repository URL and authentication token (likely for programmatic access).
    -   `external_secrets_role_arn`: ARN of the IAM role for External Secrets Operator.
    -   `jenkins_kaniko_role_arn`: ARN of the IAM role for Jenkins/Kaniko to interact with ECR.

-   **Providers and Variables (`provider.tf`, `variables.tf`):**
    -   **Provider:** `aws` configured for `us-east-1`.
    -   **Variables:** Define configurable parameters like `aws_region`, `cluster_name`, `vpc_cidr`, subnet CIDRs, EKS node capacities, and S3 bucket names. `bucket` is explicitly required, while `bucket_state` has a default.

### 2. `terraform/manifests`

This directory is responsible for deploying Kubernetes resources (manifests) primarily for ArgoCD applications and secret management. It relies on a Bastion host for execution, as indicated by the GitHub Actions workflow.

* **Backend Configuration (`backend.tf`):**
    ```terraform
    terraform {
      backend "s3" {
        bucket  = "iti-graduation-730335506473"
        key = "terraform/state/infra-manifests"
        region = "us-east-1"
      }
    }
    ```
    This state file is stored in the same S3 bucket but with a different key: `terraform/state/infra-manifests`.

        ```terraform
        terraform {
          backend "s3" {
            bucket = "iti-graduation-730335506473"
            key = "terraform/state/infra-manifests"
            region = "us-east-1"
          }
        }
        ```

        This state file is stored in the same S3 bucket but with a different key: `terraform/state/infra-manifests`.

-   **Remote State Data Sources:**

    -   `data "terraform_remote_state" "platform"`: Retrieves outputs from the `terraform/platform` state, specifically the S3 bucket and region used for that state.
    -   `data "terraform_remote_state" "infra"`: Retrieves outputs from the `terraform/infra` state, also using the S3 bucket and region. This is crucial for getting values like `external_secrets_role_arn` and `jenkins_kaniko_role_arn` from the infrastructure layer.

-   **Kubernetes Manifests (ArgoCD Applications):**
    These `kubernetes_manifest` resources define **ArgoCD `Application` objects**. Each `Application` tells ArgoCD how to deploy a specific part of your application or monitoring stack by pointing to a Helm chart or Kustomize directory in your Git repository.
    * `mysql_app`, `redis_app`, `ingress_app`: Deploy their respective Helm charts from `cd/mysql`, `cd/redis`, and `cd/ingress`. They are configured for automated synchronization with pruning and self-healing.
    * `backend_app`, `frontend_app`: Deploy their Helm charts from `cd/backend` and `cd/frontend`. Crucially, these include **annotations for ArgoCD Image Updater**. These annotations instruct ArgoCD to:
        * Monitor ECR images (`730335506473.dkr.ecr.us-east-1.amazonaws.com/backend:latest`, `frontend:latest`).
        * Use `git` as the write-back method to update the `main` branch.
        * Update the image tag using the `newest-build` strategy.
        * Target `helmvalues:values.yaml` and update the `image.tag` and `image.repository` fields within the Helm chart's `values.yaml` file. This is the core of your GitOps image update strategy.
    * `monitoring`: Deploys the Kustomize resources from `cd/monitoring` into the `monitoring` namespace, also with automated sync.

    -   `mysql_app`, `redis_app`, `ingress_app`: Deploy their respective Helm charts from `cd/mysql`, `cd/redis`, and `cd/ingress`. They are configured for automated synchronization with pruning and self-healing.
    -   `backend_app`, `frontend_app`: Deploy their Helm charts from `cd/backend` and `cd/frontend`. Crucially, these include **annotations for ArgoCD Image Updater**. These annotations instruct ArgoCD to:
        -   Monitor ECR images (`730335506473.dkr.ecr.us-east-1.amazonaws.com/backend:latest`, `frontend:latest`).
        -   Use `git` as the write-back method to update the `main` branch.
        -   Update the image tag using the `newest-build` strategy.
        -   Target `helmvalues:values.yaml` and update the `image.tag` and `image.repository` fields within the Helm chart's `values.yaml` file. This is the core of your GitOps image update strategy.
    -   `monitoring`: Deploys the Kustomize resources from `cd/monitoring` into the `monitoring` namespace, also with automated sync.

-   **Secrets Management (External Secrets Operator related):**

    -   `kubernetes_manifest "secretstore"`: Deploys a `SecretStore` Custom Resource (CR) for External Secrets Operator, defining where it should fetch secrets (e.g., AWS Secrets Manager). It uses `yamldecode(file("secrets/secretstore.yaml"))`.
    -   `kubernetes_manifest "secrets_sa"`: Deploys a Kubernetes Service Account for the External Secrets Operator, annotated with the `external_secrets_role_arn` from the `infra` module to grant it necessary AWS IAM permissions. It uses `yamldecode(templatefile("secrets/secrets_sa.yaml.tpl", ...))`.
    -   `kubernetes_manifest "secrets"`: Deploys two `ExternalSecret` Custom Resources (CRs) (for `mysql` and `redis`). These tell External Secrets Operator to fetch specific secrets from AWS Secrets Manager and create corresponding Kubernetes secrets. It uses `yamldecode(templatefile("secrets/template.yaml.tpl", ...))`.
    -   `kubernetes_secret "repo"`: Creates a Kubernetes Secret named `private-repo` in the `argocd` namespace. This secret is of type `repository` for ArgoCD, containing the `url`, `username` (`var.github_name`), and `password` (`var.github_token`) for your Git repository. This allows ArgoCD to clone your private repository.

-   **Outputs (`output.tf`):**

    -   `message`: A simple output "hello from manfiests".

-   **Providers and Variables (`provider.tf`, `variables.tf`):**
    -   **Providers:** `aws` (version `~> 5.0`) and `kubernetes`. The `kubernetes` provider is configured to use your local `~/.kube/config` file, implying this Terraform is run in an environment that can access the EKS cluster (like the Bastion host).
    -   **Variables:** `region`, `bucket` (for remote state), `repo` (your Git repository URL), `github_name`, `github_token`.

### 3. `terraform/platform`

This directory deploys critical platform components on your EKS cluster using Helm charts and Kubernetes manifests. It also leverages the Bastion host for execution.

-   **Backend Configuration (`backend.tf`):**

    ```terraform
    terraform {
      backend "s3" {
        bucket  = "iti-graduation-730335506473"
        key = "terraform/state/infra-platform"
        region = "us-east-1"
      }
    }
    ```

    This state is also in the same S3 bucket, but with the key `terraform/state/infra-platform`.

-   **Remote State Data Source:**

    -   `data "terraform_remote_state" "infra"`: Retrieves outputs from the `terraform/infra` state, including `ecr_url` and `jenkins_kaniko_role_arn`.

-   **Local Values (`locals.tf`):**

* **Custom Kubernetes Manifests:**
    * `kubernetes_manifest "letsencrypt_issuer"`: Defines a `ClusterIssuer` for `cert-manager` named `letsencrypt`, using the `ACME` protocol with Let's Encrypt for automatic certificate issuance. It specifies an email for notifications and uses HTTP-01 challenges via the `nginx` ingress class.
    * `kubernetes_manifest "app_certificate"`, `argocd_certificate`, `jenkins_certificate`, `prometheus_certificate`, `grafana_certificate`, `alertmanager_certificate`: These resources define individual `Certificate` objects for each application/tool, instructing `cert-manager` to obtain and manage TLS certificates for their respective domain names (e.g., `app.danielfarag.cloud`, `argocd.danielfarag.cloud`) using the `letsencrypt` ClusterIssuer.

-   **Kubernetes and Helm Deployments:**

    -   `kubernetes_secret "argocd_image_updater_secret"`: Creates an Opaque Kubernetes Secret named `aws-token` in the `argocd` namespace. This secret contains ECR credentials (derived from `ecr_token` from the `infra` module) that ArgoCD Image Updater uses to authenticate with ECR.
    -   `helm_release "argocd"`: Installs ArgoCD into the `argocd` namespace using its official Helm chart. It configures the ArgoCD host based on `var.domain_name`.
    -   `helm_release "argocd-image-updater"`: Installs ArgoCD Image Updater, also in the `argocd` namespace. It depends on `helm_release.argocd` and the `argocd_image_updater_secret`.
    -   `helm_release "jenkins"`: Installs Jenkins into the `jenkins` namespace using its official Helm chart, configuring its host.
    -   `helm_release "external_secrets"`: Installs the External Secrets Operator into the `external-secrets` namespace, ensuring CRDs are installed.
    -   `helm_release "kube_prometheus_stack"`: Installs the `kube-prometheus-stack` (including Prometheus, Grafana, Alertmanager) into the `monitoring` namespace, configuring their respective hosts.
    -   `helm_release "certbot"`: Installs `cert-manager` into the default namespace, ensuring CRDs are installed. This is critical for automated TLS certificate management.

-   **Custom Kubernetes Manifests:**

    -   `kubernetes_manifest "letsencrypt_issuer"`: Defines a `ClusterIssuer` for `cert-manager` named `letsencrypt`, using the `ACME` protocol with Let's Encrypt for automatic certificate issuance. It specifies an email for notifications and uses HTTP-01 challenges via the `nginx` ingress class.
    -   `kubernetes_manifest "app_certificate"`, `argocd_certificate`, `jenkins_certificate`, `prometheus_certificate`, `grafana_certificate`, `alertmanager_certificate`: These resources define individual `Certificate` objects for each application/tool, instructing `cert-manager` to obtain and manage TLS certificates for their respective domain names (e.g., `app.itilabs.net`, `argocd.itilabs.net`) using the `letsencrypt` ClusterIssuer.

-   **Modules for Network Services:**

    -   `module "nginx-ingress"`:
        -   **Source:** `./ingress-controller` (local module).
        -   **Purpose:** Deploys the NGINX Ingress Controller.
        -   **Inputs:** `eks_core_dns`.
    -   `module "route53"`:
        -   **Source:** `./route53` (local module).
        -   **Purpose:** Configures Route 53 DNS records to point to the NGINX Ingress Controller's Load Balancer, making your services publicly accessible.
        -   **Inputs:** `nginx_lb_dns`, `domain_name`, and hosts for `jenkins`, `argocd`, `prometheus`, `grafana`, `alertmanager`, and `app`.

-   **Service Accounts and Storage Class:**

    -   `kubernetes_service_account "jenkins_sa"`: Creates a Kubernetes Service Account named `jenkins-kaniko-sa` in the `jenkins` namespace. It's annotated with the `jenkins_kaniko_role_arn` from the `infra` module, granting Jenkins the necessary AWS permissions for building and pushing Docker images (e.g., to ECR using Kaniko).
    -   `kubernetes_manifest "ebs_csi"`: Deploys a Kubernetes StorageClass manifest for the Amazon EBS CSI driver, enabling dynamic provisioning of EBS volumes for persistent storage.

-   **Outputs (`output.tf`):**

    -   `storage_class`: Outputs the name of the EBS CSI storage class.

-   **Providers and Variables (`provider.tf`, `variables.tf`):**
    -   **Providers:** `aws` (version `~> 4.16`), `kubernetes` (using `~/.kube/config`), and `helm` (also using `~/.kube/config`).
    -   **Variables:** `region`, `bucket` (for remote state), `domain_name`, `cert-email` (for Let's Encrypt).

---

### Key Takeaways

-   **Modular Design:** The use of local modules (`./modules/vpc`, `./modules/eks`, etc.) promotes reusability and organization within your Terraform code.
-   **State Management:** All three Terraform configurations use S3 for remote state, ensuring state persistence and team collaboration.
-   **Remote State Data Sources:** You effectively use `data "terraform_remote_state"` to pass outputs between different Terraform root modules, creating a robust dependency chain for infrastructure, platform, and application deployments.
-   **GitOps Integration:** The `terraform/manifests` directory is central to your GitOps strategy, deploying ArgoCD `Application` resources and crucially, configuring **ArgoCD Image Updater annotations** to automate image updates directly into your Git repository.
-   **Secrets Management:** The integration with AWS Secrets Manager and External Secrets Operator through Terraform is well-defined, enhancing the security of your application credentials.
-   **Full Observability and Connectivity:** The `terraform/platform` directory ensures that your cluster has essential tools like Jenkins, ArgoCD, Prometheus, Grafana, Alertmanager, and handles ingress and DNS for public access and HTTPS.
-   **Bastion-driven Deployments:** The design implies that `terraform/manifests` and `terraform/platform` are executed from a Bastion host that has `kubectl` access to your EKS cluster and can interact with AWS SSM, which aligns with the GitHub Actions workflows we discussed previously.

This comprehensive Terraform setup provides a solid foundation for your GitOps pipeline, automating nearly every aspect of your infrastructure and application deployment.
