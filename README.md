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

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="create"></a> [create](#input\_create) | Whether to create SQS queue. | `bool` | `true` |
| <a name="create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | enable sns topic or not. | `bool` | `true` |
| <a name="content_based_deduplication"></a> [content\_based\_deduplication](#input\_content\_based\_deduplication) | Enables content-based deduplication for FIFO queues. | `bool` | `true` |
| <a name="delay_seconds"></a> [delay\_seconds](#input\_delay\_seconds) | The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). | `number` | `5` |
| <a name="fifo_queue"></a> [fifo\_queue](#input\_fifo\_queue) | Boolean designating a FIFO queue. | `bool` | `false` |
| <a name="fifo_throughput_limit"></a> [fifo\_throughput\_limit](#input\_fifo\_throughput\_limit) | Specifies whether the FIFO queue throughput quota applies to the entire queue or per message groupWorks only on FIFO Level. | `string` | `null` |
| <a name="deduplication_scope"></a> [deduplication\_scope](#input\_deduplication\_scope) | Specifies whether message deduplication occurs at the message group or queue level. Works only on FIFO Level. | `string` | `null` |
| <a name="max_message_size"></a> [max\_message\_size](#input\_max\_message\_size) | The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). | `number` | `2048` |
| <a name="message_retention_seconds"></a> [message\_retention\_seconds](#input\_message\_retention\_seconds) | The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). | `number` | `1800` |
| <a name="name"></a> [name](#input\_name) | This is the human-readable name of the queue. If omitted, Terraform will assign a random name. | `string` | `""` |
| <a name="use_name_prefix"></a> [use\_name\_prefix](#input\_mail\_from\_email\_domain) | Determines whether `name` is used as a prefix. | `bool` | `false` |
| <a name="receive_wait_time_seconds"></a> [receive\_wait\_time\_seconds](#input\_receive\_wait\_time\_seconds) | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). | `number` | `10` |
| <a name="sqs_managed_sse_enabled"></a> [sqs\_managed\_sse\_enabled](#input\_sqs\_managed\_sse\_enabled) | Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys. | `bool` | `false` |
| <a name="visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). | `number` | `60` |
| <a name="create_queue_policy"></a> [create\_queue\_policy](#input\_create\_queue\_policy) | Whether to create SQS queue policy. | `bool` | `true` |
| <a name="create_dlq"></a> [create](#input\_create\_dlq) | Determines whether to create SQS dead letter queue. | `bool` | `true` |
| <a name="dlq_content_based_deduplication"></a> [dlq\_content\_based\_deduplication](#input\_dlq\_content\_based\_deduplication) | Enables content-based deduplication for FIFO queues. | `bool` | `true` |
| <a name="dlq_delay_seconds"></a> [dlq\_delay\_seconds](#input\_dlq\_delay\_seconds) | The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). | `number` | `5` |
| <a name="dlq_deduplication_scope"></a> [dlq\_deduplication\_scope](#input\_dlq\_deduplication\_scope) | Specifies whether message deduplication occurs at the message group or queue level. Works only on FIFO Level. | `string` | `null` |
| <a name="dlq_message_retention_seconds"></a> [dlq\_message\_retention\_seconds](#input\_dlq\_message\_retention\_seconds) | The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). | `number` | `1800` |
| <a name="dlq_name"></a> [dlq\_name](#input\_dlq\_name) | This is the human-readable name of the queue. If omitted, Terraform will assign a random name. | `string` | `""` |
| <a name="dlq_receive_wait_time_seconds"></a> [dlq\_receive\_wait\_time\_seconds](#input\_dlq\_receive\_wait\_time\_seconds) | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). | `number` | `10` |
| <a name="dlq_sqs_managed_sse_enabled"></a> [dlq\_sqs\_managed\_sse\_enabled](#input\_dlq\_sqs\_managed\_sse\_enabled) | Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys. | `bool` | `false` |
| <a name="dlq_visibility_timeout_seconds"></a> [dlq\_visibility\_timeout\_seconds](#input\_dlq\_visibility\_timeout\_seconds) | The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). | `number` | `60` |
| <a name="create_dlq_queue_policy"></a> [create\_dlq\_queue\_policy](#input\_create\_dlq\_queue\_policy) | Whether to create SQS queue policy. | `bool` | `true` |
| <a name="dlq_redrive_allow_policy"></a> [dlq\_redrive\_allow\_policy](#input\_dlq\_redrive\_allow\_policy) | The JSON policy to set up the Dead Letter Queue redrive permission, see AWS docs. | `any` | `{}` |
| <a name="redrive_policy"></a> [redrive\_policy](#input\_redrive\_policy) | The JSON policy to set up the Dead Letter Queue, see AWS docs. Note: when specifying maxReceiveCount, you must specify it as an integer (5), and not a string (\"5\"). | `any` | `{}` |



## Outputs

| Name | Description |
|------|-------------|
| <a name="queue_id"></a> [queu\_id](#output\_queue\_id) | The URL for the created Amazon SQS queue |
| <a name="queue_arn"></a> [queue\_arn](#output\_queue\_arn) | The ARN of the SQS queue |
| <a name="queue_url"></a> [queue\_url](#output\_queue\_url) | Same as `queue_id`: The URL for the created Amazon SQS queue |
| <a name="queue_name"></a> [queue\_name](#output\_queue\_name) | The name of the SQS queue |
| <a name="dead_letter_queue_id"></a> [dead\_letter\_queue\_id](#output\_dead\_letter\_queue\_id) | The URL for the created Amazon DLQ-SQS queue |
| <a name="dead_letter_queue_arn"></a> [dead\_letter\_queue\_arn](#output\_dead\_letter\_queue\_arn) | The ARN of the DLQ-SQS queue |
| <a name="dead_letter_queue_url"></a> [dead\_letter\_queue_url](#output\_dead\_letter\_queue_url) | Same as `dead_letter_queue_id`: The URL for the created Amazon DLQ-SQS queue |
| <a name="dead_letter_queue_name"></a> [dead\_letter\_queue_name](#output\_dead\_letter\_queue_name) | The name of the DLQ-SQS queue |

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
