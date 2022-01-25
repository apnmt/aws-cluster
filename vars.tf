variable "environment" {
  type        = string
  description = "Environment Name"
}

variable "region" {
  default     = "eu-central-1"
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

variable "s3_bucket_id" {
  type        = string
  description = "S3 Bucket id"
  default     = "apnmt-aws-applications"
}