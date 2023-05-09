#General
variable "Environment" {
  description = "Environment name of the project like production, staging or developement"
  type        = string
  default     = ""
} 

variable "app_name" {
  description = "Name of the Application which we have to deploy"
  type        = string
  default     = ""
} 

variable additional_tags {
  description = "additional tags which we will add if any user or company requires"
  type = map(string)
  default ={ 
    Owner = ""
    Terraform = "true"
  }
}

# Network
variable "vpc_id" {
  description = "VPC id where the load balancer, ASG, application instances and other resources will be deployed"
  type        = string
  default     = ""
}

#Load Balancer
variable "alb_public_subnets" {
  description = "public subnets to provision the loadbalancer. Make sure the availability zones are same as provided to application subnets "
  type        = list(string)
  default     = null
}

variable "application_port" {
  description = "the port to be exposed by application over loadbalancer listener. This port will be mapped to Security group of ASG"
  type = map(string)
  default = {
    backend_protocol = "HTTP"
    backend_port = 80
  }
}

variable alb_configuration {
  description = "Configuration for the application load balancer to be associated with instance group. "
  type = map(string)
  default = {
    stickiness_enabled = true
    stickiness_type = "lb_cookie"
    stickiness_cookie_duration_sec = 600
    target_type = "instance"
  }
}

variable service_health_check {
  description = "Configuration for the application load balancer to perform the health checks on the instances. Matcher will be the success codes on which application response ito the health check path"
  type = map(string)
  default = {
    path = "/"
    matcher = 200
    protocol = "HTTP"
    timeout_sec = "15"
    interval_sec = "30"
  }
}

#acm
variable "acm_domain_name" {
  description = "The complete domain name for which the ACM certificate to be issued"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "ID of DNS zone or Hosted Zone hosted in Route 53"
  type        = string
  default     = null
}

# ASG configuration
variable "asg_ami_id" {
  description = "The AMI which is to be used to launch the application instance"
  type        = string
  default     = ""
}

variable "asg_instance_type" {
  description = "The type of the application instance which is used to deploy the application"
  type        = string
  default     = "t3a.small"
}

variable "min_asg_capacity" {
  description = "The minimum size ( number of instances ) of the autoscaling group to maintain at all times"
  type        = number
  default     = 1
}

variable "max_asg_capacity" {
  description = "The maximum size ( number of instances ) of the autoscaling group that can be added to Autoscaling group"
  type        = number
  default     = 1
}

variable "desired_asg_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group under ideal conditions"
  type        = number
  default     = 1
}

variable "app_private_subnets" {
  description = "private subnets to launch the application into. Subnets automatically determine which availability zones the group will reside."
  type        = list(string)
  default     = null
}


# Scaling Configuration
variable cpu_based_scaling_policy {
  description = "Scaling Policy based on CPU Utilization"
  type        = map(string)
  default = {
    enabled = true
    target_cpu_utilization_precentage = 80
    #target_cpu_utilization_period_sec = 300
  }
}

variable alb_req_count_based_scaling_policy {
  description = "Scaling Policy based on ALB Request Number of Count Per Target"
  type        = map(string)
  default = {
    enabled = true
    target_alb_req_count_per_sec = 8000
    #target_alb_req_count_period_sec = 300
  }
}

variable mem_based_scaling_policy {
  description = "Scaling Policy based on RAM/memory Utilization"
  type        = map(string)
  default = {
    enabled = true
    target_mem_utilization_precentage_low = 50
    target_mem_utilization_precentage_high = 80
    #target_mem_utilization_period_sec = 300
  }
}

variable sqs_queue_depth_based_scaling_policy {
description = "Scaling Policy based on SQS Queue Depth"
  type        = map(string)
  default = {
    enabled = true
    target_sqs_queue_name  = "my_queue"
    target_sqs_queue_depth = 80
    #target_sqs_queue_depth_period_sec = 300
  }
}


# pipeline
variable "stream_name" {
  description = "cloudwatch logs stream name for pipeline"
  type        = string
  default     = ""
}

variable "group_name" {
  description = "cloudwatch logs group name for pipeline "
  type        = string
  default     = ""
}

variable "source_location" {
  description = "source location of github (repo link) "
  type        = string
  default     = ""
}

variable "output_artifacts" {
  description = "output_artifacts of pipeline "
  type        = string
  default     = ""
}

variable "FullRepositoryId" {
  description = "github repo ID . don't include http/https "
  type        = string
  default     = ""
}

variable "BranchName" {
  description = "BranchName of github repo which you want to deploy "
  type        = string
  default     = "master"
}

variable "mailID" {
  description = "mail id where user want simple notification service "
  type        = string
  default     = ""
}

variable "region" {
  description = "region in which application should be deployed "
  type        = string
  default     = "us-west-2"
}