variable "api_proxy" {
  description = "API proxy url"
  type        = string
}

variable "api_logs_retention_days" {
  description = "API logs retention period in days"
  type        = number
}

variable "api_stage_name" {
  description = "API stage name"
  type        = string
}

variable "service_discovery_arns" {
  description = "Service discovery services arns"
  type        = map(string)
}

variable "vpc_link_id" {
  description = "VPC link id"
  type        = string
}

variable "openapi_file" {
  description = "OpenAPI file spec"
  type        = string
}