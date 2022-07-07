# #==== Create Repository ======#
# resource "aws_ecr_repository" "clixx_ecr_repo" {
#   name                 = var.repository_name
#   image_tag_mutability = "MUTABLE"
# }

#==== Create Cluster ======#
resource "aws_ecs_cluster" "clixx_cluster" {
  name = "Clixx-Cluster-Tf"
}

#====Waiting time for the docker image to be pushed to the repo ====#
resource "time_sleep" "docker" {
  depends_on = [
    aws_autoscaling_group.ecs-ASG-tf
  ]
  create_duration = "540s"
}

#==== Create Task ======#
resource "aws_ecs_task_definition" "task_definition" {
  depends_on = [
    time_sleep.docker,
    aws_ecr_repository.clixx_ecr_repo
  ]
  family             = "Clixx-Web-Task"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
  memory       = "2gb"
  cpu          = "1vCPU"
  network_mode = "bridge"
  container_definitions = jsonencode([
    {
      name = "Clixx-Web-Task-Container"
      #image     = "${aws_ecr_repository.clixx_ecr_repo.repository_url}:clixxvpc-img-tf-1.0"
      # image       = "${local.test_tf_cedentials.test_account_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/${var.repository_name}:${var.REPO_TAG}-1.0"
      image       = "743650199199.dkr.ecr.${var.AWS_REGION}.amazonaws.com/${var.repository_name}:${var.REPO_TAG}-1.0"
      cpu         = 10
      memory      = 300
      networkMode = "bridge"
      essential   = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "TCP"
        }
      ]
    }
  ])
  requires_compatibilities = ["EC2"]
  tags = {
    Name = "Clixx-Web-Task-Definition"
  }
}

#==== Create Service ======#
resource "aws_ecs_service" "clixx-web-service" {
  depends_on                         = [aws_lb.clixx-ALB-ECS-tf]
  name                               = "Clixx-Web-Service"
  cluster                            = aws_ecs_cluster.clixx_cluster.id
  task_definition                    = aws_ecs_task_definition.task_definition.arn
  desired_count                      = "2"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "EC2"
  scheduling_strategy                = "REPLICA"
  enable_ecs_managed_tags            = true
  load_balancer {
    target_group_arn = aws_lb_target_group.clixx-ecs-tg.id
    container_name   = "Clixx-Web-Task-Container"
    container_port   = 80
  }
}
