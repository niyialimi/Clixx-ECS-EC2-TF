# Create ALB for ECS
resource "aws_lb" "clixx-ALB-ECS-tf" {
  name               = "Clixx-ALB-ECS-tf"
  load_balancer_type = "network"
  tags = {
    Name = "Clixx-ALG-tf"
  }
  subnets = [aws_subnet.public_subnet.*.id[0], aws_subnet.public_subnet.*.id[1]]
}

# Create Target group for ECS
resource "aws_lb_target_group" "clixx-ecs-tg" {
  name        = "Clixx-ECS-TG-tf"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.clixx_vpc.id
  target_type = "instance"

  # health_check {
  #   interval            = 30
  #   path                = "/"
  #   port                = 80
  #   healthy_threshold   = 5
  #   unhealthy_threshold = 2
  #   timeout             = 5
  #   protocol            = "HTTP"
  #   matcher             = "200-499"
  # }
}

# Create ALB Listener
resource "aws_lb_listener" "clixx_ecs_listener" {
  load_balancer_arn = aws_lb.clixx-ALB-ECS-tf.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clixx-ecs-tg.id
  }
}

# Create Target group for Bastion
resource "aws_lb_target_group" "clixx-bastion-tg" {
  name        = "Clixx-Bastion-TG-tf"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.clixx_vpc.id
  target_type = "instance"
  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200-499"
  }
}

# Create ALB for ECS
resource "aws_lb" "clixx-ALB-Bastion-tf" {
  name               = "Clixx-ALB-Bastion-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_bastion_sg.id]
  tags = {
    Name = "Clixx-ALG-tf"
  }
  subnets = [aws_subnet.public_subnet.*.id[0], aws_subnet.public_subnet.*.id[1]]
}

# Create ALB Listener
resource "aws_lb_listener" "clixx_bastion_listener" {
  load_balancer_arn = aws_lb.clixx-ALB-Bastion-tf.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clixx-bastion-tg.arn
  }
}

# Create Auto Scaling Group Bastion
resource "aws_autoscaling_group" "bastion-ASG-tf" {
  name                  = "Bastion-ASG-tf"
  desired_capacity      = 1
  max_size              = 4
  min_size              = 1
  force_delete          = true
  depends_on            = [aws_lb.clixx-ALB-Bastion-tf]
  target_group_arns     = [aws_lb_target_group.clixx-bastion-tg.arn]
  health_check_type     = "ELB"
  launch_configuration  = aws_launch_configuration.bastion-launch-config.name
  vpc_zone_identifier   = [aws_subnet.public_subnet.*.id[0], aws_subnet.public_subnet.*.id[1]]
  protect_from_scale_in = true
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "Bastion-Server-Clixx"
    propagate_at_launch = true
  }
}

# Create Auto Scaling Group ECS Instance
resource "aws_autoscaling_group" "ecs-ASG-tf" {
  name                      = "ECS-ASG-tf"
  vpc_zone_identifier       = [aws_subnet.private_server_subnet.*.id[0], aws_subnet.private_server_subnet.*.id[1]]
  launch_configuration      = aws_launch_configuration.ecs-launch-config.name
  target_group_arns         = [aws_lb_target_group.clixx-ecs-tg.arn]
  desired_capacity          = 1
  max_size                  = 4
  min_size                  = 1
  force_delete              = true
  depends_on                = [aws_lb.clixx-ALB-ECS-tf, aws_instance.docker_ec2]
  health_check_grace_period = 30
  health_check_type         = "EC2"
  protect_from_scale_in     = true
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "Clixx-Server-ECS"
    propagate_at_launch = true
  }
}


