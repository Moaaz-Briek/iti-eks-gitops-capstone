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

