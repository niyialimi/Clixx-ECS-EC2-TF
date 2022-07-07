#Specify key pair 
resource "aws_key_pair" "Stack_KP" {
  key_name   = "stack_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

#Create Launch config for Bastion
resource "aws_launch_configuration" "bastion-launch-config" {
  depends_on = [
    aws_db_instance.rds_db_tf,
    aws_lb.clixx-ALB-ECS-tf
  ]
  name_prefix                 = "Bastion-Server"
  image_id                    = var.bastion_ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.Stack_KP.key_name
  security_groups             = ["${aws_security_group.elb_bastion_sg.id}"]
  associate_public_ip_address = true
  iam_instance_profile        = data.aws_iam_instance_profile.ssm-instance-prof.name
  user_data = base64encode(templatefile("${path.module}/scripts/bootstrap_bastion.tpl",
    {
      RDS_ENDPOINT = element(split(":", aws_db_instance.rds_db_tf.endpoint), 0)
  }))
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = "false"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Adding SSM Agent
data "aws_iam_instance_profile" "ssm-instance-prof" {
  name = "AmazonSSMRoleForInstancesQuickSetup"
}


# Create ecs instance
resource "aws_launch_configuration" "ecs-launch-config" {
  name_prefix                 = "ECS-Server-Clixx"
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "c4.large"
  security_groups             = [aws_security_group.webserver_sg.id]
  key_name                    = aws_key_pair.Stack_KP.key_name
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  associate_public_ip_address = true
  user_data                   = <<EOF
  #! /bin/bash
  sudo echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
  sudo echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
  EOF

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = "false"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}

resource "aws_instance" "docker_ec2" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.elb_bastion_sg.id]
  key_name             = aws_key_pair.Stack_KP.key_name
  iam_instance_profile = data.aws_iam_instance_profile.ssm-instance-prof.name
  user_data = base64encode(templatefile("${path.module}/scripts/bootstrap.tpl",
    {
      lb_record       = aws_lb.clixx-ALB-ECS-tf.dns_name,
      RDS_ENDPOINT    = element(split(":", aws_db_instance.rds_db_tf.endpoint), 0)
      ECR_NAME        = "${var.repository_name}",
      test_ACCESS_KEY = "${local.test_tf_cedentials.test_access_key}",
      test_SECRET_KEY = "${local.test_tf_cedentials.test_secret_key}",
      AWS_REGION      = "${var.AWS_REGION}",
      ACCOUNT_ID      = "${local.test_tf_cedentials.test_account_id}",
      TAG             = "${var.REPO_TAG}"
  }))

  tags = {
    Name = "Docker-Launch"
  }
  subnet_id                   = aws_subnet.public_subnet.*.id[0]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}
