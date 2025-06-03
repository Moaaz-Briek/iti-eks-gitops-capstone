variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "az_count" {
  type        = number
  description = "Number of AZs."
  default     = 3
}
