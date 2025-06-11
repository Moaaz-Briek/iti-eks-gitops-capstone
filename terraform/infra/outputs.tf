# ########################### NETWORK #####################################

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC."
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "IDs of the public subnets."
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "IDs of the private subnets."
}

# ########################### CLUSTER #####################################

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster."
}

output "bastion_id" {
  value = module.bastion.instance_id
}

########################### ECR #####################################

output "ecr_url" {
  value       = module.ecr.ecr_url
  description = "ECR URL"
}


output "ecr_token" {
  value = module.ecr.ecr_password
}


##################### EXTERNAL SECRET  ###################
output "external_secrets_role_arn" {
  value = module.secrets.external_secrets_role_arn
}


output "jenkins_kaniko_role_arn" {
  value = module.ecr.jenkins_kaniko_role_arn
}