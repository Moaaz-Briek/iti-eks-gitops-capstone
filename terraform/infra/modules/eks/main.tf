
##################################################################
####################### Private Cluster ##########################
##################################################################

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = "1.33"
  role_arn = aws_iam_role.eks_cluster_role.arn
  access_config {
    authentication_mode = "API"
  }
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.eks.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]
}



##################################################################
################ Nodes Template [ Active SSM ] ###################
##################################################################

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_capacity
    min_size     = var.node_min_capacity
    max_size     = var.node_max_capacity
  }

  instance_types = var.node_instance_types

  depends_on = [
    aws_iam_role_policy_attachment.node_policies
  ]
}
