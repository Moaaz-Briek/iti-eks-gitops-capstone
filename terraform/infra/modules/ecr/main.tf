locals {
  repos = ["backend", "frontend", "mysql", "redis", "jenkins/inbound-agent", "jenkins/kaniko"]
}

resource "aws_ecr_repository" "ecr" {
  count = length(local.repos)
  name                 = element(local.repos, count.index)
  image_tag_mutability = "MUTABLE"

  force_delete = true
}


resource "aws_ecr_lifecycle_policy" "backend_policy" {
  count = length(local.repos)

  repository = aws_ecr_repository.ecr[count.index].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        selection    = {
          tagStatus     = "any",
          countType     = "sinceImagePushed",
          countUnit     = "days",
          countNumber   = 14
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
