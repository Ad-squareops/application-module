#General
variable "environment" {
  description = "Environment name of the project like production, staging or developement"
  type        = string
  default     = ""
}

variable "app_name" {
  description = "Name of the Application which we have to deploy"
  type        = string
  default     = ""
}

variable "metrics_enabled" {
  description = "A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`"
  type        = bool
  default     = false
}


# Network
variable "vpc_id" {
  description = "VPC id where the load balancer, ASG, application instances and other resources will be deployed"
  type        = string
  default     = ""
}

#Load Balancer
variable "alb_enabled" {
  description = "enbale ALB or not"
  type        = bool
  default     = true
}

variable "alb_public_subnets" {
  description = "public subnets to provision the loadbalancer. Make sure the availability zones are same as provided to application subnets "
  type        = list(string)
  default     = null
}

variable "application_port" {
  description = "the port to be exposed by application over loadbalancer listener. This port will be mapped to Security group of ASG"
  type        = map(string)
  default = {
    backend_protocol = "HTTP"
    backend_port     = 80
  }
}

variable "alb_configuration" {
  description = "Configuration for the application load balancer to be associated with instance group. "
  type        = map(string)
  default = {
    stickiness_enabled             = true
    stickiness_type                = "lb_cookie"
    stickiness_cookie_duration_sec = 600
    target_type                    = "instance"
  }
}

variable "service_health_check" {
  description = "Configuration for the application load balancer to perform the health checks on the instances. Matcher will be the success codes on which application response ito the health check path"
  type        = map(string)
  default = {
    path         = "/"
    matcher      = 200
    protocol     = "HTTP"
    timeout_sec  = "15"
    interval_sec = "30"
  }
}

#acm
variable "app_domain_name" {
  description = "The complete domain name for which the ACM certificate to be issued"
  type        = string
  default     = ""
}

# ASG configuration
variable "ami_id" {
  description = "The AMI which is to be used to launch the application instance"
  type        = string
  default     = ""
}

variable "user_data_enable" {
  description = "want to pass user data or not"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "user data script which user have to pass"
  type        = string
  default     = null
}

variable "asg_instance_type" {
  description = "The type of the application instance which is used to deploy the application"
  type        = string
  default     = "t3a.small"
}

variable "health_check_type" {
  description = "type of health check EC2 or ELB"
  type        = string
  default     = "EC2"
}

variable "min_capacity" {
  description = "The minimum size ( number of instances ) of the autoscaling group to maintain at all times"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "The maximum size ( number of instances ) of the autoscaling group that can be added to Autoscaling group"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group under ideal conditions"
  type        = number
  default     = 1
}

variable "app_private_subnets" {
  description = "private subnets to launch the application into. Subnets automatically determine which availability zones the group will reside."
  type        = list(string)
  default     = null
}

variable "use_default_image" {
  description = "default ubuntu image with version 22.x"
  type        = bool
  default     = false
}

variable "ebs_device_name" {
  description = "name of the ebs volume device name"
  type        = string
  default     = ""
}

variable "ebs_volume_size" {
  description = "size of the ebs volume device"
  type        = number
  default     = 10
}

variable "ebs_volume_type" {
  description = "type of the ebs volume device"
  type        = string
  default     = ""
}

# Scaling Configuration
variable "cpu_based_scaling_policy" {
  description = "Scaling Policy based on CPU Utilization"
  type        = map(string)
  default = {
    enabled                           = true
    target_cpu_utilization_precentage = 80
    #target_cpu_utilization_period_sec = 300
  }
}

variable "alb_req_count_based_scaling_policy" {
  description = "Scaling Policy based on ALB Request Number of Count Per Target"
  type        = map(string)
  default = {
    enabled                      = true
    target_alb_req_count_per_sec = 8000
    #target_alb_req_count_period_sec = 300
  }
}

variable "mem_based_scaling_policy" {
  description = "Scaling Policy based on RAM/memory Utilization"
  type        = map(string)
  default = {
    enabled                                = true
    target_mem_utilization_precentage_low  = 50
    target_mem_utilization_precentage_high = 80
    #target_mem_utilization_period_sec = 300
  }
}

variable "region" {
  description = "region in which application should be deployed "
  type        = string
  default     = "us-west-2"
}

variable "route53_hosted_zone_domain" {
  description = "route 53 hosted zone domain in which our app sub domain will be published"
  type        = string
  default     = "skaf.squareops.in"
}

variable "ingress_rules_alb" {
  description = "ingress rules for application load balancer seucrity group"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {
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
}

variable "ingress_rules_asg" {
  description = "ingress rules for autoscaling group seucrity group"
  type = map(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = {
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
      security_groups = [""]
    }
    https = {
      from_port       = 443
      to_port         = 443
      protocol        = "TCP"
      security_groups = [""]
    }
  }
}
