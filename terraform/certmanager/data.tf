data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "terraform/state/infra"
    region = var.region
  }
}
