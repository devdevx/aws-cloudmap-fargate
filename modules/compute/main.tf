resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ecr_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_cloudwatch" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_cloud_map" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudMapFullAccess"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "task_definition" {
  for_each = { for file in var.task_files : file => jsondecode(file("${file}")) }

  family                   = each.value["family"]
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value["cpu"]
  memory                   = each.value["memory"]
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    for container in each.value["container_definitions"] : {
      name         = container["name"]
      image        = container["image"]
      cpu          = container["cpu"]
      memory       = container["memory"]
      logConfiguration = {
          logDriver: "awslogs"
          options: {  
          "awslogs-group": "/aws/ecs/${container["name"]}/logs",
          "awslogs-region":var.region,
          "awslogs-stream-prefix": "ecs"
          }
      }
      portMappings = [
        for port in container["portMappings"] : {
          containerPort = port["containerPort"]
          hostPort      = port["hostPort"]
          protocol      = port["protocol"]
        }
      ]
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  for_each = aws_ecs_task_definition.task_definition

  name              = "/aws/ecs/${each.value.family}/logs"
  retention_in_days = var.api_logs_retention_days
}

resource "aws_service_discovery_service" "service" {
  for_each = aws_ecs_task_definition.task_definition

  name = "ecs_sds_${each.value.family}"
  dns_config {
    namespace_id = var.service_discovery_namespace_id
    dns_records {
      type = "SRV"
      ttl  = 60
    }
  }
}

resource "aws_ecs_service" "task" {
  for_each = aws_ecs_task_definition.task_definition

  name            = each.value.family
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = each.value.arn
  launch_type     = "FARGATE"
  desired_count   = lookup(var.desired_tasks_count, each.value.family, 1)
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.fargate_sg_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service[each.key].arn
    port = jsondecode(each.value.container_definitions)[0]["portMappings"][0]["containerPort"]
  }
}
