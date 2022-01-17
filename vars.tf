variable "environment" {
  type        = string
  description = "Environment Name"
}

variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}