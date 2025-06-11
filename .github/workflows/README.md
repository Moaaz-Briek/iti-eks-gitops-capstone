## 🔁 CI/CD Automation with GitHub Actions

This project leverages GitHub Actions workflows for automating key CI/CD tasks, ensuring consistent and reproducible builds and deployments. These workflows are triggered manually via `workflow_dispatch` for controlled execution.

-   **`build-backend-images.yaml`:**
    -   **Purpose:** Builds the **Node.js backend Docker image** and pushes it to Amazon ECR.
    -   **Triggers:** Manually via `workflow_dispatch`.
    -   **Steps:**
        1.  **Checkout Repo:** Clones the project repository.
        2.  **Configure AWS credentials:** Sets up AWS credentials using `aws-actions/configure-aws-credentials`.
        3.  **Login to Amazon ECR:** Authenticates Docker to Amazon ECR using `aws-actions/amazon-ecr-login`.
        4.  **Build and Push Backend Docker image:** Builds the Docker image for the backend (`./backend`) and pushes it to the configured ECR repository (e.g., `730335506473.dkr.ecr.us-east-1.amazonaws.com/backend`) with both `latest` and `github.sha` tags.
  * **`build-frontend-images.yaml`:**
      * **Purpose:** Builds the **Angular frontend Docker image** and pushes it to Amazon ECR.
      * **Triggers:** Manually via `workflow_dispatch`.
      * **Steps:**
        1.  **Checkout Repo:** Clones the project repository.
        2.  **Configure AWS credentials:** Sets up AWS credentials.
        3.  **Login to Amazon ECR:** Authenticates Docker to Amazon ECR.
        4.  **Build and Push Frontend Docker image:** Builds the Docker image for the frontend (`./frontend`) and pushes it to the configured ECR repository (e.g., `730335506473.dkr.ecr.us-east-1.amazonaws.com/frontend`) with both `latest` and `github.sha` tags.
  * **`terraform-apply-destroy-infra.yaml`:**
      * **Purpose:** Manages the **core AWS infrastructure** (VPC, EKS cluster) using Terraform.
      * **Triggers:** Manually via `workflow_dispatch` with an input `action` choosing between `apply` or `destroy`.
      * **Conditions:** Runs only if the `github.actor` is `danielfarag`.
      * **Steps:**
        1.  **Checkout repository:** Clones the project.
        2.  **Configure AWS Credentials:** Sets up AWS credentials.
        3.  **Install Terraform:** Installs the Terraform CLI.
        4.  **Create backend.tf:** Dynamically generates the Terraform S3 backend configuration for state management in the `terraform/infra` directory.
        5.  **Terraform Init:** Initializes the Terraform working directory.
        6.  **Terraform Apply/Destroy:** Executes `terraform apply --auto-approve` or `terraform destroy --auto-approve` based on the selected input `action`.
-   **`terraform-apply-destroy-manifests.yaml`:**
    -   **Purpose:** Manages the **Kubernetes manifests deployed by Terraform** (e.g., External Secrets Operator setup) using Terraform. This workflow operates via a Bastion host.
    -   **Triggers:** Manually via `workflow_dispatch` with an input `action` choosing between `apply` or `destroy`.
    -   **Steps:**
        1.  **Checkout repository:** Clones the project.
        2.  **Configure AWS Credentials:** Sets up AWS credentials.
        3.  **Get Bastion Instance ID:** Retrieves the instance ID of the running Bastion host using AWS CLI and tags.
        4.  **Run command on Bastion instance via SSM:** Uses AWS Systems Manager (SSM) to execute commands on the Bastion host. This includes:
            -   Creating the `backend.tf` for Terraform S3 state in `/root/iti-eks/terraform/manifests`.
            -   Creating `vars.tfvars` with repository details and a GitHub token for potential private repo access on the Bastion.
            -   Updating the `kubeconfig` to connect to the EKS cluster.
            -   Initializing and applying/destroying Terraform within the `/root/iti-eks/terraform/manifests` directory on the Bastion.
-   **`terraform-apply-destroy-platform.yaml`:**
    -   **Purpose:** Manages the **platform-level Kubernetes components** (Jenkins, ArgoCD, Ingress) deployed by Terraform. This workflow also operates via a Bastion host.
    -   **Triggers:** Manually via `workflow_dispatch` with an input `action` choosing between `apply` or `destroy`.
    -   **Steps:**
        1.  **Checkout repository:** Clones the project.
        2.  **Configure AWS Credentials:** Sets up AWS credentials.
        3.  **Get Bastion Instance ID:** Retrieves the instance ID of the running Bastion host.
        4.  **Run command on Bastion instance via SSM:** Uses AWS Systems Manager (SSM) to execute commands on the Bastion host. This includes:
            -   Creating the `backend.tf` for Terraform S3 state in `/root/iti-eks/terraform/platform`.
            -   Creating `vars.tfvars` with repository details.
            -   Updating the `kubeconfig` to connect to the EKS cluster.
            -   Initializing and applying/destroying Terraform within the `/root/iti-eks/terraform/platform` directory on the Bastion.
