data "aws_caller_identity" "current" {}

resource "aws_iam_role" "bastion" {
  name               = "bastion-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "eks_describe_cluster_policy" {
  name        = "EC2BastionServerAccessPolicties"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "eks:DescribeCluster",
        Resource = "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/*"
      },{
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_eks_describe_attachment" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.eks_describe_cluster_policy.arn
}



resource "aws_iam_role_policy_attachment" "bastion_ssm_attachment" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

