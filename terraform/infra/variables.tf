variable "aws_region" {
  type    = string
  default = "us-east-1"
}


variable "cluster_name" {
  type    = string
  default = "gitops-eks-cluster"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "node_instance_types" {
  description = "EKS node group instance types."
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_desired_capacity" {
  type    = number
  default = 2
}

variable "node_min_capacity" {
  type    = number
  default = 1
}

variable "node_max_capacity" {
  type    = number
  default = 3
}

variable "bucket" {
  type    = string
}
variable "bucket_state" {
  type    = string
  default = "terraform/state/infra"
}
