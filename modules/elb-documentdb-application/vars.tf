variable "application_name" {
  type = string
}
variable "s3_bucket_id" {
  type = string
}
variable "environment" {
  type    = string
  default = "test"
}
variable "solution_stack_name" {
  type    = string
  default = "64bit Amazon Linux 2 v3.2.10 running Corretto 11"
}
variable "tier" {
  type    = string
  default = "WebServer"
}
variable "instance_type" {
  type        = string
  description = "Instance Type for EC2"
}
variable "docdb_instance_type" {
  type        = string
  description = "Instance Type for RDS"
}
variable "min_size" {
  type    = number
  default = 1
}
variable "max_size" {
  type    = number
  default = 2
}
variable "cpu_lower_threshold" {
  type    = number
  default = 10
}
variable "cpu_upper_threshold" {
  type    = number
  default = 50
}
variable "vpc_id" {
  type = string
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "region" {
  type        = string
  description = "AWS region"
}
variable "aws_access_key" {
  type        = string
  description = "AWS AccessKey"
  sensitive   = true
}
variable "aws_secret_key" {
  type        = string
  description = "AWS SecretKey"
  sensitive   = true
}