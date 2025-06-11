### 🚀 3. CD Tool – ArgoCD + Argo Image Updater

ArgoCD is the core of the Continuous Delivery strategy, implementing GitOps principles. The `cd` directory contains the Kubernetes manifests managed by ArgoCD.

  * **Helm Charts for Application Components:**
      * **`backend` (Helm Chart: `ci-cd-backend`):** Manages the deployment of the Node.js backend application.
          * Uses the Docker image from `730335506473.dkr.ecr.us-east-1.amazonaws.com/backend` with a configurable tag.
          * Exposes a `ClusterIP` service named `backend-service` on port `3000`.
          * References Kubernetes secrets named `mysql-k8s-secret` and `redis-k8s-secret` for database and Redis credentials.
          * Configured with CPU and memory limits/requests for resource management.
      * **`frontend` (Helm Chart: `ci-cd-frontend`):** Manages the deployment of the Angular frontend application.
          * Uses the Docker image from `730335506473.dkr.ecr.us-east-1.amazonaws.com/frontend` with a configurable tag.
          * Exposes a `ClusterIP` service named `frontend-service` on port `80`.
          * Configured with CPU and memory limits/requests.
          * References a `ConfigMap` named `nginx-config` for frontend configuration.
      * **`mysql` (Helm Chart: `ci-cd-mysql`):** Manages the deployment of the MySQL database.
          * Uses the `docker.io/mysql:latest` image.
          * Exposes a service named `mysql`.
          * References a secret named `mysql-k8s-secret` for credentials.
          * Utilizes the `ebs-csi` storage class for persistent storage.
      * **`redis` (Helm Chart: `ci-cd-redis`):** Manages the deployment of the Redis cache.
          * Uses the `docker.io/redis:latest` image.
          * Exposes a service named `redis`.
          * References a secret named `redis-k8s-secret` for credentials.
          * Utilizes the `ebs-csi` storage class for persistent storage.
      * **`ingress` (Helm Chart: `ci-cd-frontend` - note: likely a typo in name, should be `ci-cd-ingress`):** Manages the Kubernetes Ingress resource.
          * Defines an Ingress named `app-ingress` in the `default` namespace.
          * Uses the `nginx` Ingress class and `letsencrypt` as the ClusterIssuer for TLS.
          * Exposes the application at `app.danielfarag.cloud` with `app-tls` as the TLS secret.
          * Routes traffic:
              * `/` to `frontend-service` on port `80`.
              * `/posts` to `backend-service` on port `3000`.
              * `/mysql` to `mysql` on port `3306`.
              * `/redis` to `redis` on port `6379`.
  * **Monitoring Components (Kustomize):**
      * **`alertmanager-config.yaml`**: Configures **Prometheus Alertmanager** for sending alerts via email. It defines various receivers (`me`, `critical_alerts`, `warning_alerts`, `info_alerts`) with different email addresses and routing rules based on alert severity.
      * **`grafana-dashboard.yaml`**: Defines a **Grafana Dashboard** named `posts-api-dashboard` for visualizing metrics from the Node.js backend. It includes panels for total, successful, and failed API requests, and a graph for request trends.
      * **`prometheus-backend-service.yaml`**: Defines a Kubernetes **Service** named `prometheus-backend-service` that exposes the `backend-node` application's metrics endpoint (`/metrics`) on port `8080`.
      * **`prometheus-backend-servicemonitor.yaml`**: Defines a **Prometheus ServiceMonitor** to discover the `prometheus-backend-service` and scrape metrics from the backend application.
      * **`prometheus-rule.yaml`**: Defines **Prometheus Alerting Rules** for the `posts-api`. These rules trigger alerts based on:
          * High request rate (`HighPostsAPIRequestRate`)
          * High failure rate (`HighPostsAPIFailureRate`)
          * Low request rate (`LowPostsAPIRequestRate`)
          * No requests (`NoPostsAPIRequests`)
      * **`kustomization.yaml`**: Orchestrates the deployment of the monitoring resources, applying patches to set the correct namespace (`default`) and target port for the `prometheus-backend-service` and `servicemonitor`.
  * **ArgoCD Setup:**
      * ArgoCD is configured to synchronize Kubernetes manifests directly from a Git repository.
      * It is set up for automatic deployment (GitOps).
  * **Argo Image Updater:**
      * Monitors image tags in Amazon ECR for new versions.
      * Automatically updates image tags in the Git repository (Kubernetes manifests).
      * Triggers the GitOps flow in ArgoCD upon image tag updates.
