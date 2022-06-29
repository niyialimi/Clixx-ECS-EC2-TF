# iam_policy_document.ecs.tf
data "aws_iam_policy_document" "ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

# iam_role.ecs.tf
resource "aws_iam_role" "ecs" {
  assume_role_policy = data.aws_iam_policy_document.ecs.json
  name               = "clixx-ecsInstanceRole"
}

# iam_role_policy_attachment.ecs.tf
resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# iam_instance_profile.ecs.tf
resource "aws_iam_instance_profile" "ecs" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs.name
}

#--------------------------------
#==== Create ECS IAM Role ======#
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.cluster_name}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

#==== Create ECS IAM Role Policy======#
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#==== Attach Policy to ECS IAM Role ======#
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#-------------------------------------
#==== Create ECS IAM Role ======#
resource "aws_iam_role" "ecs_service_execution_role" {
  name               = "${var.cluster_name}-ecsServiceExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.service_assume_role_policy.json
}

#==== Create ECS IAM Role Policy======#
data "aws_iam_policy_document" "service_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

#==== Attach Policy to ECS IAM Role ======#
resource "aws_iam_role_policy_attachment" "ecsServiceExecutionRole_policy" {
  role       = aws_iam_role.ecs_service_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
