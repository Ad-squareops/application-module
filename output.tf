output "name_of_application" {
  description = "The name of Application"
  value       = var.app_name
}

output "alb_security_group_id" {
  description = "ALB security group id"
  value       = aws_security_group.alb-security_group[0].id
}

output "autoscaling_group_details" {
  description = "The autoscaling group details"
  value = {
    autoscaling_group_id                = module.asg.autoscaling_group_id
    autoscaling_group_name              = module.asg.autoscaling_group_name
    autoscaling_group_min_size          = module.asg.autoscaling_group_min_size
    autoscaling_group_max_size          = module.asg.autoscaling_group_max_size
    autoscaling_group_desired_capacity  = module.asg.autoscaling_group_desired_capacity
    autoscaling_group_health_check_type = module.asg.autoscaling_group_health_check_type
  }
}

output "application_load_balancer" {
  description = "The application load balancer details"
  value = {
    load_balancer_id         = var.alb_enabled ? module.application_load_balancer[0].lb_id : null
    load_balancer_arn        = var.alb_enabled ? module.application_load_balancer[0].lb_arn : null
    load_balancer_dns_name   = var.alb_enabled ? module.application_load_balancer[0].lb_dns_name : null
    load_balancer_zone_id    = var.alb_enabled ? module.application_load_balancer[0].lb_zone_id : null
    load_balancer_arn_suffix = var.alb_enabled ? module.application_load_balancer[0].lb_arn_suffix : null
  }
}

output "target_group_details" {
  description = "The target group details"
  value = {
    target_group_names        = var.alb_enabled ? module.application_load_balancer[0].target_group_names[0] : null
    target_group_arns         = var.alb_enabled ? module.application_load_balancer[0].target_group_arns[0] : null
    target_group_arn_suffixes = var.alb_enabled ? module.application_load_balancer[0].target_group_arn_suffixes[0] : null
  }
}

output "launch_template_details" {
  description = "launch template config details"
  value = {
    key_pair_name             = module.key_pair.key_pair_name
    iam_instance_profile_arn  = aws_iam_instance_profile.instance-profile.arn
    iam_instance_profile_name = aws_iam_instance_profile.instance-profile.name
  }
}
