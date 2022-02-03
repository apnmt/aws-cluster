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
variable "environment_variables" {
  type        = map(string)
  description = "Lambda Environment Variables"
}