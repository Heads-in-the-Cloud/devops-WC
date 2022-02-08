
resource "aws_ecs_cluster" "utopia-cluster" {
  name = "utopia-cluster-WC"
}


resource "aws_ecs_task_definition" "task_definitions" {
  for_each                 =  var.task_definitions
  family                   = each.value["family"]
  task_role_arn            = aws_iam_role.api_ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.api_ecs_task_execution_role.arn
  network_mode             = each.value["network_mode"]
  cpu                      = each.value["cpu"]
  memory                   = each.value["memory"]
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode([
  {
    name                   = each.value["container_name"]
    image                  = each.value["image"]
    cpu                    = 10
    memory                 = 512
    network_mode           = each.value["network_mode"]
    environment            = var.environment
    secrets                = each.value["container_secrets"]
    portMappings = [
      {
        containerPort = var.app_port
        hostPort      = var.app_port
      }
      ]
    },
  ]) 
}


resource "aws_ecs_service" "ecs_services" {
    for_each          = var.ecs_services
    name              = each.value["name"]
    cluster           = aws_ecs_cluster.utopia-cluster.id
    task_definition   = aws_ecs_task_definition.task_definitions[ each.value["task_name"] ].id
    desired_count     = each.value["desired_count"]
    launch_type       = "FARGATE"

    network_configuration {
      security_groups  = [aws_security_group.service_sg.id]
      subnets          = var.public_subnet_ids
      assign_public_ip = true
    }

    load_balancer {
      target_group_arn = each.value["target_group_arn"]
      container_name   = each.value["container_name"]
      container_port   = var.app_port
    }
    depends_on = [ var.booking_rule, var.flight_rule ]

}



resource "aws_security_group" "service_sg" {
  name        = "service_sg_WC"
  description = "Allow all TCP from load balancer sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [ var.alb_sg_id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "service_sg_WC"
  }

}