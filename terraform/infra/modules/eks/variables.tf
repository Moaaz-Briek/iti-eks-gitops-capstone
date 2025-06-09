variable "region" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS control plane/nodes."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet cidrs for EKS control plane/nodes."
  type        = list(string)
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.micro"]
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


variable "s3_bucket" {
  type    = string
}

variable "s3_bucket_state" {
  type    = string
}

variable "bastion_role_arn" {
  type = string
}