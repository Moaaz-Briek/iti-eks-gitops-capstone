output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "node_group_role_arn" {
  value = aws_iam_role.node_group.arn
}

output "eks_oidc_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "eks_oidc_issuer" {
  value = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}