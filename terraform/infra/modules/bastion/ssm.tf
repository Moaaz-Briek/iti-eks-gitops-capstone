
################################################################
####################### SSM ENDPOINTS ##########################
################################################################

resource "aws_security_group" "ssm_vpc_endpoint" {
  name        = "${var.cluster_name}-ssm-endpoint-sg"
  description = "Security group for SSM VPC Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
    description = "Allow HTTPS from EKS private subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-ssm-endpoint-sg"
  }
}


resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.ssm_vpc_endpoint.id]
  private_dns_enabled = true 

  tags = {
    Name = "${var.cluster_name}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.ssm_vpc_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.cluster_name}-ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.ssm_vpc_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.cluster_name}-ec2messages-endpoint"
  }
}
