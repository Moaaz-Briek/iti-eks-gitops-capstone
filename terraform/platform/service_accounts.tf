resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = "jenkins-kaniko-sa"
    namespace = "jenkins"

    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.infra.outputs.jenkins_kaniko_role_arn
    }
  }

}
