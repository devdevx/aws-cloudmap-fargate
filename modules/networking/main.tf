resource "aws_vpc" "private_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    name = "private_vpc"
  }
}

resource "aws_subnet" "private_vpc_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.private_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.private_vpc.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  tags = {
    name = "private_subnet_${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.private_vpc.id
  tags = {
    name = "private_route_table"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_vpc_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "fargate_sg" {
  vpc_id = aws_vpc.private_vpc.id
  name   = "fargate_sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.private_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_vpc_subnets[*].id
  security_group_ids  = [aws_security_group.fargate_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.private_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_vpc_subnets[*].id
  security_group_ids  = [aws_security_group.fargate_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloud_map" {
  vpc_id              = aws_vpc.private_vpc.id
  service_name        = "com.amazonaws.${var.region}.servicediscovery"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_vpc_subnets[*].id
  security_group_ids  = [aws_security_group.fargate_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.private_vpc.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_vpc_subnets[*].id
  security_group_ids  = [aws_security_group.fargate_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = aws_vpc.private_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_vpc_subnets[*].id
  security_group_ids  = [aws_security_group.fargate_sg.id]
  private_dns_enabled = true
}

# Required to pull auth for ECR
resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id              = aws_vpc.private_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_vpc_subnets[*].id
  security_group_ids  = [aws_security_group.fargate_sg.id]
  private_dns_enabled = true
}

# Required to pull private ECR images
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.private_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id]
}

resource "aws_apigatewayv2_vpc_link" "ecs_vpc_link" {
  name               = "ecs_vpc_link"
  subnet_ids         = aws_subnet.private_vpc_subnets[*].id
  security_group_ids = [aws_security_group.fargate_sg.id]
}

resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name = "ecs.internal"
  vpc  = aws_vpc.private_vpc.id
}
