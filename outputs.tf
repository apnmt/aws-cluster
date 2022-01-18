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