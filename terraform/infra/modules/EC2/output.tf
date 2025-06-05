output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = aws_instance.bastion_host.public_ip
}

output "bastion_private_ip" {
  description = "The private IP address of the bastion host"
  value       = aws_instance.bastion_host.private_ip
}

output "ssh_command" {
  description = "Example SSH command to connect to the bastion host"
  value       = "ssh -i ~/.ssh/${var.bastion_key_name}.pem ubuntu@${aws_instance.bastion_host.public_ip}"
}
