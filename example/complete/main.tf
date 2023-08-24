locals {
  region                     = "us-east-2"
  environment                = "prod"
  app_name                   = "demosops"
  vpc_id                     = "vpc-08f755b2542b7c16a"
  user_data_enable           = true
  user_data                  = <<-EOT
    #!/bin/bash
    echo "Hello Terraform!"
  EOT
  route53_hosted_zone_domain = "skaf.squareops.in"
  app_domain_name            = "demosops.prod.skaf.squareops.in" #skaf.sqauerops.in is the hosted zone. subdomain will be published in this for the application
  additional_tags = {
    Owner      = "squareops"
    Expires    = "Never"
    Department = "Engineering"
  }
}

module "application" {
  source = "../../"

  environment         = local.environment
  app_name            = local.app_name
  app_private_subnets = ["subnet-071c42172f8e7c580"]
  min_capacity        = 1
  max_capacity        = 1
  desired_capacity    = 1
  metrics_enabled     = false
  health_check_type   = "EC2"
  user_data           = base64encode(local.user_data)

  # Launch template
  ami_id            = "ami-0430580de6244e02e"
  asg_instance_type = "t3a.small"
  use_default_image = false ### if default image is true then don't pass the asg ami id
  ebs_device_name   = "/dev/sda1"
  ebs_volume_size   = 20
  ebs_volume_type   = "gp2"

  #Load balancer
  vpc_id             = local.vpc_id
  alb_public_subnets = ["subnet-00b6bc5653565011b", "subnet-01706e0ebaac37151"]
  app_domain_name    = local.app_domain_name

  #the port to be exposed by application over loadbalancer listener
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

  cpu_based_scaling_policy = {
    enabled                           = true
    target_cpu_utilization_precentage = 80
  }

  alb_req_count_based_scaling_policy = {
    enabled                      = true
    target_alb_req_count_per_sec = 8000
  }

  mem_based_scaling_policy = {
    enabled                                = false
    target_mem_utilization_precentage_high = 80
    target_mem_utilization_precentage_low  = 50
  }

  service_health_check = {
    path         = "/"
    matcher      = 200
    protocol     = "HTTP"
    timeout_sec  = "5"
    interval_sec = "30"
  }

  ingress_rules_alb = {
    all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    test = {
      from_port   = 34
      to_port     = 34
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress_rules_asg = {
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    http = {
      from_port       = 80
      to_port         = 80
      protocol        = "TCP"
      security_groups = [module.application.alb_security_group_id]
    }
    https = {
      from_port       = 443
      to_port         = 443
      protocol        = "TCP"
      security_groups = [module.application.alb_security_group_id]
    }
  }
}
