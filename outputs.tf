output "api_gateway_invoke_url" {
  description = "Url to invoke Api Gateway"
  value       = "${aws_api_gateway_deployment.deployment.invoke_url}${aws_api_gateway_stage.stage.stage_name}/"
}

output "cognito_user_pool_id" {
  description = "User Pool Id"
  value       = data.aws_cognito_user_pools.apnmt_user_pool.ids.0
}

output "cognito_user_pool_client_id" {
  description = "User Pool Client Id"
  value       = data.aws_cognito_user_pool_clients.apnmt_user_pool_client.client_ids.0
}

output "appointmentservice_endpoint_url" {
  description = "Appointmentservice endpoint url"
  value       = module.appointmentservice-application.elb_endpoint_url
}

output "appointmentservice_rds_hostname" {
  description = "Appointmentservice RDS instance hostname"
  value       = module.appointmentservice-application.rds_hostname
  sensitive   = true
}

output "appointmentservice_rds_port" {
  description = "Appointmentservice RDS instance port"
  value       = module.appointmentservice-application.rds_port
  sensitive   = true
}

output "appointmentservice_rds_username" {
  description = "Appointmentservice RDS instance username"
  value       = module.appointmentservice-application.rds_username
  sensitive   = true
}

output "appointmentservice_rds_password" {
  description = "Appointmentservice RDS instance password"
  value       = module.appointmentservice-application.rds_password
  sensitive   = true
}

output "organization_appointmentservice_documentdb_hostname" {
  description = "OrganizationAppointmentservice DocumentDB instance hostname"
  value       = module.organization-appointmentservice-application.documentdb_hostname
  sensitive   = true
}

output "organization_appointmentservice_documentdb_port" {
  description = "OrganizationAppointmentservice DocumentDB instance port"
  value       = module.organization-appointmentservice-application.documentdb_port
  sensitive   = true
}

output "organization_appointmentservice_documentdb_username" {
  description = "OrganizationAppointmentservice DocumentDB instance username"
  value       = module.organization-appointmentservice-application.documentdb_username
  sensitive   = true
}

output "organization_appointmentservice_documentdb_password" {
  description = "OrganizationAppointmentservice DocumentDB instance password"
  value       = module.organization-appointmentservice-application.documentdb_password
  sensitive   = true
}