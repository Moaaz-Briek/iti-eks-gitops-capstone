output "ingress_hosts" {
  value = {
    jenkins    = var.jenkins_host
    argocd     = var.argocd_host
    prometheus = var.prometheus_host
    grafana    = var.grafana_host
    app    = var.app_host
  }
}
