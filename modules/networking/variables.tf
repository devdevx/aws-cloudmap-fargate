variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}