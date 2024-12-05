output "service_discovery_arns" {
  value = { for service, sd in aws_service_discovery_service.service : sd.name => sd.arn }
}
