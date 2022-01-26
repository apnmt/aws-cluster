variable "application_name" {
  type = string
}
variable "handler" {
  type = string
}
variable "s3_bucket_id" {
  type = string
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