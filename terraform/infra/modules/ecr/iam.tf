
resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.eks_oidc_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_issuer, "https://", "")}:sub" = "system:serviceaccount:jenkins:jenkins-kaniko-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "jenkins_kaniko" {
  name = "JenkinsKanikoECR"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "jenkins_kaniko_role_attachment" {
  role       = aws_iam_role.jenkins_kaniko_role.name
  policy_arn = aws_iam_policy.jenkins_kaniko.arn
}
