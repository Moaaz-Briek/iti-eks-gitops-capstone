output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "node_group_role_arn" {
  value = aws_iam_role.node_group.arn
}


output "terraform_pod_role_arn" {
  value = aws_iam_role.terraform_pod_role.arn
}

output "eks_oidc_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}

