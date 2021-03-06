output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds-instance.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds-instance.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.rds-instance.username
  sensitive   = true
}

output "rds_password" {
  description = "RDS instance root password"
  value       = aws_db_instance.rds-instance.password
  sensitive   = true
}

output "elb_endpoint_url" {
  description = "ELB endpoint url"
  value       = aws_elastic_beanstalk_environment.environment.endpoint_url
}