output "ecr_url" {
  value = aws_ecr_repository.ecr[*].repository_url
}

output "ecr_password" {
  value = data.external.ecr_token.result.password
}

output "jenkins_kaniko_role_arn" {
  value=aws_iam_role.jenkins_kaniko_role.arn
}