resource "kubernetes_manifest" "mysql_app" {
  depends_on = [kubernetes_secret.repo]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "mysql-project"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repo
        targetRevision = "main"
        path           = "cd/mysql"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}


resource "kubernetes_manifest" "redis_app" {
  depends_on = [kubernetes_secret.repo]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "redis-project"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repo
        targetRevision = "main"
        path           = "cd/redis"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}

resource "kubernetes_manifest" "ingress_app" {
  depends_on = [kubernetes_secret.repo]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "ingress-project"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repo
        targetRevision = "main"
        path           = "cd/ingress"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}


resource "kubernetes_manifest" "backend_app" {
  depends_on = [kubernetes_secret.repo]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "backend-project"
      namespace = "argocd"
      annotations =  {
        "argocd-image-updater.argoproj.io/image-list": "backend-node=730335506473.dkr.ecr.us-east-1.amazonaws.com/backend:latest",
        "argocd-image-updater.argoproj.io/write-back-method": "git",
        "argocd-image-updater.argoproj.io/git-branch": "main",
        "argocd-image-updater.argoproj.io/backend-node.update-strategy": "newest-build",
        "argocd-image-updater.argoproj.io/write-back-target": "helmvalues:values.yaml",
        "argocd-image-updater.argoproj.io/backend-node.helm.image-tag": "image.tag",
        "argocd-image-updater.argoproj.io/backend-node.helm.image-name": "image.repository"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repo
        targetRevision = "main"
        path           = "cd/backend"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}


resource "kubernetes_manifest" "frontend_app" {
  depends_on = [kubernetes_secret.repo]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "frontend-project"
      namespace = "argocd"
      annotations =  {
        "argocd-image-updater.argoproj.io/image-list": "frontend=730335506473.dkr.ecr.us-east-1.amazonaws.com/frontend:latest",
        "argocd-image-updater.argoproj.io/write-back-method": "git",
        "argocd-image-updater.argoproj.io/git-branch": "main",
        "argocd-image-updater.argoproj.io/frontend.update-strategy": "newest-build",
        "argocd-image-updater.argoproj.io/write-back-target": "helmvalues:values.yaml",
        "argocd-image-updater.argoproj.io/frontend.helm.image-tag": "image.tag",
        "argocd-image-updater.argoproj.io/frontend.helm.image-name": "image.repository"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repo
        targetRevision = "main"
        path           = "cd/frontend"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}


resource "kubernetes_manifest" "monitoring" {
  depends_on = [kubernetes_secret.repo]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "monitoring"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repo
        targetRevision = "main"
        path           = "cd/monitoring"
        kustomize      = {}
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "monitoring"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}
