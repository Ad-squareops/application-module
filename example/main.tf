locals {
  region          = "ap-south-1"
  vpc_cidr        = "	172.31.0.0/16"
  Environment     = "prod"
  app_name        = "demosops"
  vpc_id          = "vpc-0b802ed52b6a2d09a"
  route53_zone_id = "Z001615877EDY2WUMEW6"
  acm_domain_name = "skaf.squareops.in"
  additional_tags = {
    Owner      = "squareops"
    Expires    = "Never"
    Department = "Engineering"
  }
}

module "asg" {
  source = "../module/"

  Environment          = local.Environment
  app_name             = local.app_name
  app_private_subnets  = ["subnet-0a922c6f66dc35a69"]
  min_asg_capacity     = 1
  max_asg_capacity     = 1
  desired_asg_capacity = 1
  enabled_metrics      = false

  # Launch template
  asg_ami_id        = "ami-08e5424edfe926b43"
  asg_instance_type = "t3a.small"
  use_default_image = false


  #Load balancer
  vpc_id             = local.vpc_id
  alb_public_subnets = ["subnet-044e1ac384f464b00", "subnet-07f69540d40775872"]
  route53_zone_id    = local.route53_zone_id
  acm_domain_name    = local.acm_domain_name


  application_port = {
    backend_protocol = "HTTP"
    backend_port     = 80
  }

  alb_configuration = {
    stickiness_enabled             = true
    stickiness_type                = "lb_cookie"
    stickiness_cookie_duration_sec = 600
    target_type                    = "instance"
  }

  service_health_check = {
    path         = "/"
    matcher      = 200
    protocol     = "HTTP"
    timeout_sec  = "5"
    interval_sec = "30"
  }
}

