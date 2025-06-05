


# Name of an existing EC2 Key Pair in your AWS account.
variable "bastion_key_name" {
  description = "Name of the EC2 Key Pair to use for the bastion host"
  type        = string
  # IMPORTANT: REPLACE THIS WITH THE NAME OF YOUR EXISTING KEY PAIR!
  default = "my-ssh-key" # <<< --- Change this ---
}
