#
# API ALB security group resources
#
resource "aws_security_group_rule" "alb_http_ingress" {
  type             = "ingress"
  from_port        = 80
  to_port          = 80
  protocol         = "tcp"
  cidr_blocks      = [var.external_access_cidr_block]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_https_ingress" {
  type             = "ingress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = [var.external_access_cidr_block]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.alb.id
}

# US-East Whitelist

data "aws_ip_ranges" "us_east_ec2" {
  regions  = ["${var.aws_region}"]
  services = ["ec2"]
}

locals {
  ec2_cidr_block_chunks = "${chunklist(data.aws_ip_ranges.us_east_ec2.cidr_blocks, 40)}"
}

resource "aws_security_group" "franklin_server_alb_whitelist_ec2" {
  count = "${length(local.ec2_cidr_block_chunks)}"

  vpc_id = data.terraform_remote_state.core.outputs.vpc_id

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.core.outputs.container_instance_security_group_id]
  }

  tags = {
    Name        = "sgFranklinServerLoadBalancer"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "alb_franklin_server_ec2_https_ingress" {
  count = "${length(local.ec2_cidr_block_chunks)}"

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = local.ec2_cidr_block_chunks[count.index]
  security_group_id = aws_security_group.franklin_server_alb_whitelist_ec2.*.id[count.index]
}

#
# Container instance security group resources
#
resource "aws_security_group_rule" "container_instance_alb_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  security_group_id        = data.terraform_remote_state.core.outputs.container_instance_security_group_id
  source_security_group_id = aws_security_group.alb.id
}
