locals {
  addons = {
    aws-ebs-csi-driver = {
      role_arn = aws_iam_role.ebs_csi_driver_role.arn
    }
  }
}

################################################################
##################### Create EKS ADDONS ########################
################################################################
resource "aws_eks_addon" "this" {
  for_each = local.addons

  cluster_name             = var.cluster_name
  addon_name               = each.key
  service_account_role_arn = each.value.role_arn
}