output "name_of_application" {
  description = "The name of Application"
  value       = module.application.name_of_application
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.application.alb_security_group_id
}

output "autoscaling_group_details" {
  description = "The autoscaling group details"
  value       = module.application.autoscaling_group_details
}

output "application_load_balancer_details" {
  description = "The application load balancer details"
  value       = module.application.application_load_balancer
}

output "target_group_details" {
  description = "The target group details"
  value       = module.application.target_group_details
}

output "launch_template_details" {
  description = "launch template config details"
  value       = module.application.launch_template_details
}