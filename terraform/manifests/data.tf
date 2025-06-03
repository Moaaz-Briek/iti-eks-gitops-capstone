data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "terraform/state/infra-platform"
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

output "platform" {
  value = data.terraform_remote_state.platform.outputs.message
}

output "infra" {
  value = data.terraform_remote_state.infra.outputs.message
}
