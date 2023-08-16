## AutoScalingGroup Example

![squareops_avatar]

[squareops_avatar]: https://squareops.com/wp-content/uploads/2022/12/squareops-logo.png

### [SquareOps Technologies](https://squareops.com/) Your DevOps Partner for Accelerating cloud journey.
<br>
This example will be very useful for users who are new to a module and want to quickly learn how to use it. By reviewing the examples, users can gain a better understanding of how the module works, what features it supports, and how to customize it to their specific needs.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sqs"></a> [sqs](#module\_asg_) | squareops/asg/aws | n/a |


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
