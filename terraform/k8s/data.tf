data "terraform_remote_state" "helm" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "terraform/state/infra-helm"
    region = var.region
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "terraform/state/infra"
    region = var.region
  }
}

output "helm" {
  value = data.terraform_remote_state.helm.outputs.message
}

output "infra" {
  value = data.terraform_remote_state.infra.outputs.message
}

# output "test2" {
#   value = data.terraform_remote_state.helm.outputs.helm_data
# }
# data.terraform_remote_state.infra.outputs
# data.terraform_remote_state.helm.outputs.helm_data.infra_data.message
