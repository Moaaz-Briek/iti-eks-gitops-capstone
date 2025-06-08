output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "node_group_role_arn" {
  value = aws_iam_role.node_group.arn
}

output "ssm_vpc_endpoint_sg" {
  value = aws_security_group.ssm_vpc_endpoint.id
}

output "terraform_pod_role_arn" {
  value = aws_iam_role.terraform_pod_role.arn
}

output "eks_oidc_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}


########################################


# data "aws_eks_cluster_auth" "this" {
#   name = aws_eks_cluster.this.name
# }

# output "cluster_endpoint" {
#   value = aws_eks_cluster.this.endpoint
# }
# output "cluster_certificate_authority_data" {
#   value = aws_eks_cluster.this.certificate_authority[0].data
# }
# output "cluster_token" {
#   value = data.aws_eks_cluster_auth.this.token
# }