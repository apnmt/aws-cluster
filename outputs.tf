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