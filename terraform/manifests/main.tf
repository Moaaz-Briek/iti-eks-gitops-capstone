resource "kubernetes_manifest" "mysql_app" {
  depends_on = [ kubernetes_secret.repo ]
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
          prune     = true
          selfHeal  = true
        }
      }
    }
  }
}


resource "kubernetes_manifest" "redis_app" {
  depends_on = [ kubernetes_secret.repo ]
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
          prune     = true
          selfHeal  = true
        }
      }
    }
  }
}

resource "kubernetes_manifest" "ingress_app" {
  depends_on = [ kubernetes_secret.repo ]
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
          prune     = true
          selfHeal  = true
        }
      }
    }
  }
}


resource "kubernetes_manifest" "backend_app" {
  depends_on = [ kubernetes_secret.repo ]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "backend-project"
      namespace = "argocd"
      annotations =  {
        "argocd-image-updater.argoproj.io/image-list": "backend-node=478614263566.dkr.ecr.us-east-1.amazonaws.com/backend:latest",
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
          prune     = true
          selfHeal  = true
        }
      }
    }
  }
}


resource "kubernetes_manifest" "frontend_app" {
  depends_on = [ kubernetes_secret.repo ]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "frontend-project"
      namespace = "argocd"
      annotations =  {
        "argocd-image-updater.argoproj.io/image-list": "frontend=478614263566.dkr.ecr.us-east-1.amazonaws.com/frontend:latest",
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
          prune     = true
          selfHeal  = true
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


resource "kubernetes_manifest" "letsencrypt_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt"
      namespace = "cert-manager"
    }
    spec = {
      acme = {
        email   = var.cert-email
        server  = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-tls-secret"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "mydomain_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "app-cert"
      namespace = "default"
    }
    spec = {
      secretName = "app-tls"
      dnsNames  = ["app.itilabs.net"]
      issuerRef = {
        name = "letsencrypt"
        kind = "Issuer"
      }
    }
  }
}

resource "kubernetes_manifest" "mydomain_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "argocd-cert"
      namespace = "default"
    }
    spec = {
      secretName = "argocd-tls"
      dnsNames  = ["argocd.itilabs.net"]
      issuerRef = {
        name = "letsencrypt"
        kind = "Issuer"
      }
    }
  }
}

resource "kubernetes_manifest" "mydomain_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "jenkins-cert"
      namespace = "default"
    }
    spec = {
      secretName = "jenkins-tls"
      dnsNames  = ["jenkins.itilabs.net"]
      issuerRef = {
        name = "letsencrypt"
        kind = "Issuer"
      }
    }
  }
}

resource "kubernetes_manifest" "mydomain_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "prometheus-cert"
      namespace = "default"
    }
    spec = {
      secretName = "prometheus-tls"
      dnsNames  = ["prometheus.itilabs.net"]
      issuerRef = {
        name = "letsencrypt"
        kind = "Issuer"
      }
    }
  }
}

resource "kubernetes_manifest" "mydomain_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "grafana-cert"
      namespace = "default"
    }
    spec = {
      secretName = "grafana-tls"
      dnsNames  = ["grafana.itilabs.net"]
      issuerRef = {
        name = "letsencrypt"
        kind = "Issuer"
      }
    }
  }
}

resource "kubernetes_manifest" "mydomain_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "alertmanager-cert"
      namespace = "default"
    }
    spec = {
      secretName = "alertmanager-tls"
      dnsNames  = ["alertmanager.itilabs.net"]
      issuerRef = {
        name = "letsencrypt"
        kind = "Issuer"
      }
    }
  }
}
