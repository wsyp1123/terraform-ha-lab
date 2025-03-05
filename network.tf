resource "aws_security_group" "lb_security_gp" {
  name        = "alb-sg"
  description = "Allow all http inbound traffic to load balancer and outbound traffic to instances only"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb-inbound" {
  security_group_id = aws_security_group.lb_security_gp.id
  cidr_ipv4         = local.anywhere
  from_port         = local.http_port
  ip_protocol       = local.tcp_protocol
  to_port           = local.http_port
}



resource "aws_vpc_security_group_egress_rule" "alb-outbound" {
  security_group_id            = aws_security_group.lb_security_gp.id
  referenced_security_group_id = aws_security_group.ec2_security_gp.id
  from_port                    = local.http_port
  ip_protocol                  = local.tcp_protocol
  to_port                      = local.http_port
}


resource "aws_security_group" "ec2_security_gp" {
  name        = "ec2-sg"
  description = "Allow inbound traffic from load balancer and outbound traffic to all"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2-inbound" {
  security_group_id            = aws_security_group.ec2_security_gp.id
  referenced_security_group_id = aws_security_group.lb_security_gp.id
  from_port                    = local.http_port
  ip_protocol                  = local.tcp_protocol
  to_port                      = local.http_port
}



resource "aws_vpc_security_group_egress_rule" "ec2-outbound" {
  security_group_id = aws_security_group.ec2_security_gp.id
  cidr_ipv4         = local.anywhere
  ip_protocol       = local.all_ports
}

