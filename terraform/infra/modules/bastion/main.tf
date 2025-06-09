data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion_server" {
  ami           = data.aws_ami.ubuntu.id
  subnet_id     = var.private_subnet_ids[0]
  instance_type = "t2.micro"
  user_data_replace_on_change = true
  user_data   = base64encode(templatefile("${path.module}/script.sh", {
    cluster_name = var.cluster_name,
    region       = var.region,
  }))
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  tags = {
    Name = "bastion"
  }
}