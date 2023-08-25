## AutoScalingGroup Module

![squareops_avatar]

[squareops_avatar]: https://squareops.com/wp-content/uploads/2022/12/squareops-logo.png

### [SquareOps Technologies](https://squareops.com/) Your DevOps Partner for Accelerating cloud journey.
<br>

This module deploys AutoScalingGroup, Application Load Balancer majorly and small resources required to launch an application. With this module, take the advantage of AutoScalingGroup and Application Load Balancer installation in your AWS account. This module will deploy ASG, ALB, ACM, scaling policies, pem-key to secrets manager and route 53 sub domain which will be used for your application and domain and acm mapping to ALB for https support.

## Important Notes:
This module is compatible with all the terraform versions which is great news for users deploying the module on AWS running account. Reviewed the module's documentation, meet specific configuration requirements, and test thoroughly after deployment to ensure everything works as expected.


## Usage Example

```hcl

module "application" {
  source = "../../"

  vpc_id             = local.vpc_id
  app_name            = local.app_name
  environment         = local.environment
  user_data           = base64encode(local.user_data)
  min_capacity        = 1
  max_capacity        = 1
  desired_capacity    = 1
  metrics_enabled     = false
  health_check_type   = "EC2"
  app_domain_name    = local.app_domain_name
  app_private_subnets = ["subnet-071c42172f8e7c580"]
  route53_hosted_zone_name = local.route53_hosted_zone_name

  # Launch template
  ami_id            = "ami-0430580de6244e02e"
  asg_instance_type = "t3a.small"
  use_default_image = false ### if default image is true then don't pass the asg ami id
  ebs_device_name   = "/dev/sda1"
  ebs_volume_size   = 20
  ebs_volume_type   = "gp2"

  #Load balancer
  alb_public_subnets = ["subnet-00b6bc5653565011b", "subnet-01706e0ebaac37151"]

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


```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.36 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.36 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.0 |
| <a name="module_application_load_balancer"></a> [application\_load\_balancer](#module\_application\_load\_balancer) | terraform-aws-modules/alb/aws | ~> 6.0 |
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | 6.10.0 |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | squareops/keypair/aws | 1.0.2 |
| <a name="module_route53-record"></a> [route53-record](#module\_route53-record) | clouddrove/route53-record/aws | 1.0.1 |
| <a name="module_s3_bucket_alb_access_logs"></a> [s3\_bucket\_alb\_access\_logs](#module\_s3\_bucket\_alb\_access\_logs) | terraform-aws-modules/s3-bucket/aws | ~> 3.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_policy.RAM_based_scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.RAM_based_scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.asg_ALB_request_count_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.asg_cpu_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_metric_alarm.RAM_based_scale_up_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.scale_down_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.instance-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instance-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.instance-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cloudwatch-asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.alb-security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.asg-security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ubuntu_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_configuration"></a> [alb\_configuration](#input\_alb\_configuration) | Configuration for the application load balancer to be associated with instance group. | `map(string)` | <pre>{<br>  "stickiness_cookie_duration_sec": 600,<br>  "stickiness_enabled": true,<br>  "stickiness_type": "lb_cookie",<br>  "target_type": "instance"<br>}</pre> | no |
| <a name="input_alb_enabled"></a> [alb\_enabled](#input\_alb\_enabled) | enbale ALB or not | `bool` | `true` | no |
| <a name="input_alb_public_subnets"></a> [alb\_public\_subnets](#input\_alb\_public\_subnets) | public subnets to provision the loadbalancer. Make sure the availability zones are same as provided to application subnets | `list(string)` | `null` | no |
| <a name="input_alb_req_count_based_scaling_policy"></a> [alb\_req\_count\_based\_scaling\_policy](#input\_alb\_req\_count\_based\_scaling\_policy) | Scaling Policy based on ALB Request Number of Count Per Target | `map(string)` | <pre>{<br>  "enabled": true,<br>  "target_alb_req_count_per_sec": 8000<br>}</pre> | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI which is to be used to launch the application instance | `string` | `""` | no |
| <a name="input_app_domain_name"></a> [app\_domain\_name](#input\_app\_domain\_name) | The complete domain name for which the ACM certificate to be issued | `string` | `""` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the Application which we have to deploy | `string` | `""` | no |
| <a name="input_app_private_subnets"></a> [app\_private\_subnets](#input\_app\_private\_subnets) | private subnets to launch the application into. Subnets automatically determine which availability zones the group will reside. | `list(string)` | `null` | no |
| <a name="input_application_port"></a> [application\_port](#input\_application\_port) | the port to be exposed by application over loadbalancer listener. This port will be mapped to Security group of ASG | `map(string)` | <pre>{<br>  "backend_port": 80,<br>  "backend_protocol": "HTTP"<br>}</pre> | no |
| <a name="input_asg_instance_type"></a> [asg\_instance\_type](#input\_asg\_instance\_type) | The type of the application instance which is used to deploy the application | `string` | `"t3a.small"` | no |
| <a name="input_cpu_based_scaling_policy"></a> [cpu\_based\_scaling\_policy](#input\_cpu\_based\_scaling\_policy) | Scaling Policy based on CPU Utilization | `map(string)` | <pre>{<br>  "enabled": true,<br>  "target_cpu_utilization_precentage": 80<br>}</pre> | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the autoscaling group under ideal conditions | `number` | `1` | no |
| <a name="input_ebs_device_name"></a> [ebs\_device\_name](#input\_ebs\_device\_name) | name of the ebs volume device name | `string` | `""` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | size of the ebs volume device | `number` | `10` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | type of the ebs volume device | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name of the project like production, staging or developement | `string` | `""` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | type of health check EC2 or ELB | `string` | `"EC2"` | no |
| <a name="input_ingress_rules_alb"></a> [ingress\_rules\_alb](#input\_ingress\_rules\_alb) | ingress rules for application load balancer seucrity group | <pre>map(object({<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    cidr_blocks = list(string)<br>  }))</pre> | <pre>{<br>  "http": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "from_port": 80,<br>    "protocol": "TCP",<br>    "to_port": 80<br>  },<br>  "https": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "from_port": 443,<br>    "protocol": "TCP",<br>    "to_port": 443<br>  }<br>}</pre> | no |
| <a name="input_ingress_rules_asg"></a> [ingress\_rules\_asg](#input\_ingress\_rules\_asg) | ingress rules for autoscaling group seucrity group | <pre>map(object({<br>    from_port       = number<br>    to_port         = number<br>    protocol        = string<br>    cidr_blocks     = optional(list(string))<br>    security_groups = optional(list(string))<br>  }))</pre> | <pre>{<br>  "http": {<br>    "from_port": 80,<br>    "protocol": "TCP",<br>    "security_groups": [<br>      ""<br>    ],<br>    "to_port": 80<br>  },<br>  "https": {<br>    "from_port": 443,<br>    "protocol": "TCP",<br>    "security_groups": [<br>      ""<br>    ],<br>    "to_port": 443<br>  },<br>  "ssh": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "from_port": 22,<br>    "protocol": "TCP",<br>    "to_port": 22<br>  }<br>}</pre> | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum size ( number of instances ) of the autoscaling group that can be added to Autoscaling group | `number` | `1` | no |
| <a name="input_mem_based_scaling_policy"></a> [mem\_based\_scaling\_policy](#input\_mem\_based\_scaling\_policy) | Scaling Policy based on RAM/memory Utilization | `map(string)` | <pre>{<br>  "enabled": true,<br>  "target_mem_utilization_precentage_high": 80,<br>  "target_mem_utilization_precentage_low": 50<br>}</pre> | no |
| <a name="input_metrics_enabled"></a> [metrics\_enabled](#input\_metrics\_enabled) | A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances` | `bool` | `false` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | The minimum size ( number of instances ) of the autoscaling group to maintain at all times | `number` | `1` | no |
| <a name="input_region"></a> [region](#input\_region) | region in which application should be deployed | `string` | `"us-west-2"` | no |
| <a name="input_route53_hosted_zone_name"></a> [route53\_hosted\_zone\_name](#input\_route53\_hosted\_zone\_name) | route 53 hosted zone domain in which our app sub domain will be published | `string` | `"skaf.squareops.in"` | no |
| <a name="input_service_health_check"></a> [service\_health\_check](#input\_service\_health\_check) | Configuration for the application load balancer to perform the health checks on the instances. Matcher will be the success codes on which application response ito the health check path | `map(string)` | <pre>{<br>  "interval_sec": "30",<br>  "matcher": 200,<br>  "path": "/",<br>  "protocol": "HTTP",<br>  "timeout_sec": "15"<br>}</pre> | no |
| <a name="input_use_default_image"></a> [use\_default\_image](#input\_use\_default\_image) | default ubuntu image with version 22.x | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | user data script which user have to pass | `string` | `null` | no |
| <a name="input_user_data_enable"></a> [user\_data\_enable](#input\_user\_data\_enable) | want to pass user data or not | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id where the load balancer, ASG, application instances and other resources will be deployed | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | ALB security group id |
| <a name="output_application_load_balancer"></a> [application\_load\_balancer](#output\_application\_load\_balancer) | The application load balancer details |
| <a name="output_autoscaling_group_details"></a> [autoscaling\_group\_details](#output\_autoscaling\_group\_details) | The autoscaling group details |
| <a name="output_launch_template_details"></a> [launch\_template\_details](#output\_launch\_template\_details) | launch template config details |
| <a name="output_name_of_application"></a> [name\_of\_application](#output\_name\_of\_application) | The name of Application |
| <a name="output_target_group_details"></a> [target\_group\_details](#output\_target\_group\_details) | The target group details |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contribution & Issue Reporting

To report an issue with a project:

  1. Check the repository's [issue tracker](https://github.com/squareops/terraform-kubernetes-sqs/issues) on GitHub
  2. Search to see if the issue has already been reported
  3. If you can't find an answer to your question in the documentation or issue tracker, you can ask a question by creating a new issue. Be sure to provide enough context and details so others can understand your problem.

## License

Apache License, Version 2.0, January 2004 (http://www.apache.org/licensqs/).

## Support Us

To support a GitHub project by liking it, you can follow these steps:

  1. Visit the repository: Navigate to the [GitHub repository](https://github.com/squareops/terraform-kubernetes-sqs).

  2. Click the "Star" button: On the repository page, you'll see a "Star" button in the upper right corner. Clicking on it will star the repository, indicating your support for the project.

  3. Optionally, you can also leave a comment on the repository or open an issue to give feedback or suggest changes.

Starring a repository on GitHub is a simple way to show your support and appreciation for the project. It also helps to increase the visibility of the project and make it more discoverable to others.

## Who we are

We believe that the key to success in the digital age is the ability to deliver value quickly and reliably. That’s why we offer a comprehensive range of DevOps & Cloud services designed to help your organization optimize its systems & Processqs for speed and agility.

  1. We are an AWS Advanced consulting partner which reflects our deep expertise in AWS Cloud and helping 100+ clients over the last 5 years.
  2. Expertise in Kubernetes and overall container solution helps companies expedite their journey by 10X.
  3. Infrastructure Automation is a key component to the success of our Clients and our Expertise helps deliver the same in the shortest time.
  4. DevSecOps as a service to implement security within the overall DevOps process and helping companies deploy securely and at speed.
  5. Platform engineering which supports scalable,Cost efficient infrastructure that supports rapid development, testing, and deployment.
  6. 24*7 SRE service to help you Monitor the state of your infrastructure and eradicate any issue within the SLA.

We provide [support](https://squareops.com/contact-us/) on all of our projects, no matter how small or large they may be.

To find more information about our company, visit [squareops.com](https://squareops.com/), follow us on [Linkedin](https://www.linkedin.com/company/squareops-technologies-pvt-ltd/), or fill out a [job application](https://squareops.com/careers/). You can also checkout our [Case-studies](https://squareops.com/case-studies/) or [Blogs](https://squareops.com/blog/) to understand more about our solutions. If you have any questions or would like assistance with your cloud strategy and implementation, please don't hesitate to [contact us](https://squareops.com/contact-us/).
