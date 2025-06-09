resource "kubernetes_manifest" "secretstore" {
  manifest = yamldecode(file("secrets/secretstore.yaml"))
}


resource "kubernetes_manifest" "secrets_sa" {
  manifest = yamldecode(templatefile("secrets/secrets_sa.yaml.tpl", {
    role_arn = data.terraform_remote_state.infra.outputs.external_secrets_role_arn
  }))
}


resource "kubernetes_manifest" "secrets" {
  count = 2
  manifest = yamldecode(templatefile("secrets/template.yaml.tpl", {
    name = element(["mysql", "redis"], count.index)
  }))
}

resource "kubernetes_secret" "repo" {
  metadata {
    name      = "private-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name          = "iti_gp"
    type          = "git"
    url           = "https://github.com/danielfarag/iti-eks-gitops-capstone"
    username      = var.github_name
    password      = var.github_token
  }

  type = "Opaque"
}