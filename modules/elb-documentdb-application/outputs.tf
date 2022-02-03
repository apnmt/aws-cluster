output "documentdb_hostname" {
  description = "DocumentDB instance hostname"
  value       = aws_docdb_cluster.documentdb-cluster.endpoint
  sensitive   = true
}

output "documentdb_port" {
  description = "DocumentDB instance port"
  value       = aws_docdb_cluster.documentdb-cluster.port
  sensitive   = true
}

output "documentdb_username" {
  description = "DocumentDB instance root username"
  value       = aws_docdb_cluster.documentdb-cluster.master_username
  sensitive   = true
}
output "documentdb_password" {
  description = "DocumentDB instance root password"
  value       = aws_docdb_cluster.documentdb-cluster.master_password
  sensitive   = true
}

output "elb_endpoint_url" {
  description = "ELB endpoint url"
  value       = aws_elastic_beanstalk_environment.environment.endpoint_url
}