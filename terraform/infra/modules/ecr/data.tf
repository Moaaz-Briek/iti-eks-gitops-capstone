data "external" "ecr_token" {
  program = ["bash", "${path.module}/get-ecr-token.sh"]
}
