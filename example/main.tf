locals {
  vpc_cidr    = "10.0.0.0/16"
  Environment = "prod"
  #Owner           = "SquareOps"
  app_name        = "demosops"
  region          = "us-west-2"
  vpc_id          = "vpc-0b3f45c5755ae1d3e"
  route53_zone_id = "Z025421120N1PKJMEL0SR"
  acm_domain_name = "ldc.squareops.in"
}


module "asg" {
  source = "/home/ubuntu/module"

  Environment          = local.Environment
  app_name             = local.app_name
  app_private_subnets  = ["subnet-0b1bf9f367133a41d", "subnet-0558682ffd7fa198e"]
  min_asg_capacity     = 1
  max_asg_capacity     = 1
  desired_asg_capacity = 1

  # Launch template
  asg_ami_id        = "ami-0db245b76e5c21ca1"
  asg_instance_type = "t3a.small"


  #Load balancer
  vpc_id             = local.vpc_id
  alb_public_subnets = ["subnet-0ea38ad5d3b4d030b", "subnet-09d1456b4f93a6da4"]
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

  # pipeline
  stream_name = "wordpress"
  group_name = "wordpress"
  source_location = "https://github.com/Ad-squareops/wpadi1.git"
  output_artifacts = "wordpress"
  FullRepositoryId = "Ad-squareops/wpadi1"
  BranchName = "master"
  mailID = "aditya.jain@squareops.com"
}

