variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "api_logs_retention_days" {
  description = "API logs retention period in days"
  type        = number
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the service will be deployed."
  type        = list(string)
}

variable "service_discovery_namespace_id" {
  description = "Service discovery namespace id."
  type        = string
}

variable "fargate_sg_id" {
  description = "ID of the security group to be used for the ECS Fargate tasks."
  type        = string
}

variable "task_files" {
  description = "List of task JSON files in the tasks folder"
  type        = list(string)
}

variable "desired_tasks_count" {
  description = "Number of instances of each task"
  type = map(number)
}
