variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "api_stage_name" {
  description = "API stage name"
  type        = string
}

variable "api_proxy" {
  description = "API proxy url"
  type        = string
}

variable "api_logs_retention_days" {
  description = "API logs retention period in days"
  type        = number
}

variable "cluster_name" {
  description = "ECS cluster name"
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

variable "openapi_file" {
  description = "OpenAPI file spec"
  type        = string
}