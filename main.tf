#ALB Security Group
resource "aws_security_group" "alb-security_group" {
  count       = var.alb_enabled ? 1 : 0
  name        = format("%s-%s-alb-sg", var.environment, var.app_name)
  description = "Application Load Balancer Security Group"
  vpc_id      = var.vpc_id
  dynamic "ingress" {
    for_each = var.ingress_rules_alb

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "application_load_balancer" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  count              = var.alb_enabled ? 1 : 0
  name               = format("%s-%s-alb", var.environment, var.app_name)
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.alb_public_subnets
  security_groups    = [aws_security_group.alb-security_group[0].id]
  enable_http2       = true

  access_logs = {
    bucket = "${var.app_name}-access-logs"
  }

  target_groups = [
    {
      name             = format("%s-%s-TG", var.environment, var.app_name)
      backend_protocol = var.application_port.backend_protocol
      backend_port     = var.application_port.backend_port
      target_type      = var.alb_configuration.target_type
      health_check = {
        enabled             = true
        interval            = var.service_health_check.interval_sec
        path                = var.service_health_check.path
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        timeout             = var.service_health_check.timeout_sec
        protocol            = var.service_health_check.protocol
        matcher             = var.service_health_check.matcher
      },
      stickiness = {
        enabled         = var.alb_configuration.stickiness_enabled
        cookie_duration = var.alb_configuration.stickiness_cookie_duration_sec
        type            = var.alb_configuration.stickiness_type
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]


  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}

module "s3_bucket_alb_access_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.7.0"

  bucket = "${var.app_name}-access-logs"
  lifecycle_rule = [
    {
      id      = "monthly_retention"
      prefix  = "/"
      enabled = true

      expiration = {
        days = 10
      }
    }
  ]
  versioning = {
    enabled = true
  }

  force_destroy = true

  attach_elb_log_delivery_policy = true
  attach_lb_log_delivery_policy  = true
}


module "key_pair" {
  source             = "squareops/keypair/aws"
  version            = "1.0.2"
  environment        = var.environment
  key_name           = format("%s-%s-key", var.environment, var.app_name)
  ssm_parameter_path = format("%s_%s_key", var.environment, var.app_name)
}

resource "aws_security_group" "asg-security_group" {
  name        = format("%s-%s-app_asg_sg", var.environment, var.app_name)
  description = "Security group for Application Instances"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules_asg

    content {
      from_port = ingress.value.from_port
      to_port   = ingress.value.to_port
      protocol  = ingress.value.protocol

      # Either use cidr_blocks or security_groups depending on the rule type
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu_ami" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "asg" {
  source                    = "terraform-aws-modules/autoscaling/aws"
  version                   = "6.10.0"
  name                      = format("%s-%s-asg", var.environment, var.app_name)
  min_size                  = var.min_capacity
  max_size                  = var.max_capacity
  user_data                 = var.user_data_enable ? var.user_data : null
  enabled_metrics           = var.metrics_enabled ? ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"] : null
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.app_private_subnets
  wait_for_capacity_timeout = 0
  target_group_arns         = module.application_load_balancer[0].target_group_arns
  health_check_type         = "EC2"
  default_instance_warmup   = 300

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 60
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name        = "${var.app_name}-launch_template"
  launch_template_description = "Launch template for application"
  update_default_version      = true
  image_id                    = var.use_default_image ? data.aws_ami.ubuntu_ami.image_id : var.ami_id
  instance_type               = var.asg_instance_type
  key_name                    = module.key_pair.key_pair_name
  ebs_optimized               = true
  enable_monitoring           = true
  security_groups             = [aws_security_group.asg-security_group.id]
  iam_instance_profile_name   = aws_iam_instance_profile.instance-profile.name

  block_device_mappings = [
    {
      device_name = var.ebs_device_name
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.ebs_volume_size
        volume_type           = var.ebs_volume_type
      }
    }
  ]
}



# Scaling Policies
# ASGAverageCPUUtilization
resource "aws_autoscaling_policy" "asg_cpu_policy" {
  count                     = var.cpu_based_scaling_policy.enabled ? 1 : 0
  name                      = "${var.app_name}-cpu-policy"
  autoscaling_group_name    = module.asg.autoscaling_group_name
  estimated_instance_warmup = 60
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_based_scaling_policy.target_cpu_utilization_precentage
  }
}

# ALBRequestCountPerTarget
resource "aws_autoscaling_policy" "asg_ALB_request_count_policy" {
  depends_on                = [module.application_load_balancer]
  count                     = var.alb_req_count_based_scaling_policy.enabled ? 1 : 0
  name                      = "${var.app_name}-ALBRequestCountPerTarget-policy"
  autoscaling_group_name    = module.asg.autoscaling_group_name
  estimated_instance_warmup = 60
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${module.application_load_balancer[0].lb_arn_suffix}/${module.application_load_balancer[0].target_group_arn_suffixes[0]}"
    }
    target_value = var.alb_req_count_based_scaling_policy.target_alb_req_count_per_sec
  }
}

# RAM based
resource "aws_autoscaling_policy" "RAM_based_scale_up" {
  count                  = var.mem_based_scaling_policy.enabled ? 1 : 0
  name                   = "${var.app_name}-asg-RAM-scale-up-policy"
  autoscaling_group_name = module.asg.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "RAM_based_scale_down" {
  count                  = var.mem_based_scaling_policy.enabled ? 1 : 0
  name                   = "${var.app_name}-asg-RAM-scale-down-policy"
  autoscaling_group_name = module.asg.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "RAM_based_scale_up_alarm" {
  count               = var.mem_based_scaling_policy.enabled ? 1 : 0
  alarm_name          = "${var.app_name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RAM_used_percent"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.mem_based_scaling_policy.target_mem_utilization_precentage_high
  dimensions = {
    "AutoScalingGroupName" = module.asg.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.RAM_based_scale_up[0].arn]
  depends_on      = [aws_autoscaling_policy.RAM_based_scale_up]
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  count               = var.mem_based_scaling_policy.enabled ? 1 : 0
  alarm_name          = "${var.app_name}-ram-scale-down-alarm"
  alarm_description   = "asg-scale-down-ram-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RAM_used_percent"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.mem_based_scaling_policy.target_mem_utilization_precentage_low
  dimensions = {
    "AutoScalingGroupName" = module.asg.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [resource.aws_autoscaling_policy.RAM_based_scale_down[0].arn]
  depends_on      = [aws_autoscaling_policy.RAM_based_scale_down]
}


module "route53-record" {
  allow_overwrite = true
  source          = "clouddrove/route53-record/aws"
  version         = "1.0.1"
  zone_id         = data.aws_route53_zone.selected.zone_id
  name            = var.app_domain_name
  type            = "A"
  alias = {
    name                   = module.application_load_balancer[0].lb_dns_name
    zone_id                = module.application_load_balancer[0].lb_zone_id
    evaluate_target_health = true
  }
}

module "acm" {
  source              = "terraform-aws-modules/acm/aws"
  version             = "~> 4.0"
  domain_name         = var.app_domain_name
  zone_id             = data.aws_route53_zone.selected.zone_id
  wait_for_validation = true
}

data "aws_route53_zone" "selected" {
  name = var.route53_hosted_zone_domain
}
