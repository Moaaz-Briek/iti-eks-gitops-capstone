output "ecr_url" {
  value = aws_ecr_repository.ecr[*].repository_url
}

output "ecr_password" {
  value = data.external.ecr_token.result.password
}