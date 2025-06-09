
output "bastion_role_arn" {
  value = aws_iam_role.bastion.arn
}


output "instance_id" {
  value = aws_instance.bastion_server.id
}
