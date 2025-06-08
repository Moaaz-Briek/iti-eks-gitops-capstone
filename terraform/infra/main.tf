module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  az_count             = 3
}

module "eks" {
  depends_on            = [ module.vpc ]
  source                = "./modules/eks"
  cluster_name          = var.cluster_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  private_subnet_cidrs  = var.private_subnet_cidrs
  node_instance_types   = var.node_instance_types
  node_desired_capacity = var.node_desired_capacity
  node_min_capacity     = var.node_min_capacity
  node_max_capacity     = var.node_max_capacity
  region                = var.aws_region
  s3_bucket             = var.bucket
  s3_bucket_state       = var.bucket_state
}

module "ecr" {
  source = "./modules/ecr"
}

module "secrets" {
  depends_on = [ module.eks ]
  source = "./modules/secrets"
  eks_oidc_arn = module.eks.eks_oidc_arn
  cluster_name = var.cluster_name
}