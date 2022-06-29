#==== Security Group for ELB/Bastion Server ======#
resource "aws_security_group" "elb_bastion_sg" {
  name        = "Clixx-ALB-Bastion-Tf"
  description = "Allows Web Access"
  vpc_id      = aws_vpc.clixx_vpc.id
  tags = {
    Name = "Clixx-ALB-Bastion-Tf"
  }
}

resource "aws_security_group_rule" "ingress_elb_bastion_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_bastion_sg.id
}

resource "aws_security_group_rule" "egress_elb_bastion_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_bastion_sg.id
}

#==== Security Group for Application Server ======#
resource "aws_security_group" "webserver_sg" {
  name        = "Clixx-Web-Server-Tf"
  description = "Allows ALB and Bastion to access th Web Server"
  vpc_id      = aws_vpc.clixx_vpc.id
  tags = {
    Name = "Clixx-Web-Server-Tf"
  }
}

resource "aws_security_group_rule" "ingress_webserver_sg_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
}


resource "aws_security_group_rule" "ingress_webserver_sg_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  security_group_id = aws_security_group.webserver_sg.id
}

resource "aws_security_group_rule" "ingress_webserver_sg_allin" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.webserver_sg.id
  source_security_group_id = aws_security_group.elb_bastion_sg.id
}

resource "aws_security_group_rule" "engress_webserver_sg_allout" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
}

#==== Security Group for RDS Instance ======#
resource "aws_security_group" "rds_sg" {
  name        = "Clixx-RDS-Tf"
  description = "Allows Web Server to access the RDS instances"
  vpc_id      = aws_vpc.clixx_vpc.id
  tags = {
    Name = "Clixx-RDS-Tf"
  }
}

resource "aws_security_group_rule" "rds_sg_bastion_in" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.elb_bastion_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}

resource "aws_security_group_rule" "rds_sg_web_in" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}

resource "aws_security_group_rule" "rds_sg_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_sg.id
}
