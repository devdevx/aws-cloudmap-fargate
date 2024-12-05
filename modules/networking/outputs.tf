output "subnet_ids" {
  value = aws_subnet.private_vpc_subnets[*].id
}

output "ecs_vpc_link_id" {
  value = aws_apigatewayv2_vpc_link.ecs_vpc_link.id
}

output "service_discovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.namespace.id
}

output "fargate_sg_id" {
  value = aws_security_group.fargate_sg.id
}
