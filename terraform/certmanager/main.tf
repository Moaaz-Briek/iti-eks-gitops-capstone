resource "helm_release" "certbot" {
  name       = "certbot"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.8.0"

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [
    file("values/certbot-values.yaml")
  ]
}
