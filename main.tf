module "networking" {
  source = "./modules/networking"
  region = var.region
  availability_zones = var.availability_zones
}

module "compute" {
  source = "./modules/compute"
  region = var.region
  cluster_name = var.cluster_name
  api_logs_retention_days = var.api_logs_retention_days
  subnet_ids = module.networking.subnet_ids
  service_discovery_namespace_id = module.networking.service_discovery_namespace_id
  fargate_sg_id = module.networking.fargate_sg_id
  desired_tasks_count = var.desired_tasks_count
  task_files = var.task_files
}

module "api_gateway" {
  source = "./modules/api_gateway"
  api_logs_retention_days = var.api_logs_retention_days
  api_stage_name = var.api_stage_name
  api_proxy = var.api_proxy
  vpc_link_id = module.networking.ecs_vpc_link_id
  service_discovery_arns = module.compute.service_discovery_arns
  openapi_file = var.openapi_file
}