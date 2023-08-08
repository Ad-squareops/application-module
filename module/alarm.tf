resource "aws_sns_topic" "httpcode_target_5xx_count" {
  name = "${var.app_name}-httpcode_target_5xx_count"
}

resource "aws_sns_topic_subscription" "httpcode_target_5xx_count" {
  topic_arn = aws_sns_topic.httpcode_target_5xx_count.arn
  protocol  = "email"
  endpoint  = var.mailID

  depends_on = [
    aws_sns_topic.httpcode_target_5xx_count
  ]
}

resource "aws_sns_topic" "httpcode_lb_5xx_count" {
  name = "${var.app_name}-httpcode_lb_5xx_count"
}
resource "aws_sns_topic_subscription" "httpcode_lb_5xx_count" {
  topic_arn = aws_sns_topic.httpcode_lb_5xx_count.arn
  protocol  = "email"
  endpoint  = var.mailID

  depends_on = [
    aws_sns_topic.httpcode_lb_5xx_count
  ]
}

resource "aws_sns_topic" "unhealthy_hosts" {
  name = "${var.app_name}-unhealthy_hosts"
}

resource "aws_sns_topic_subscription" "unhealthy_hosts" {
  topic_arn = aws_sns_topic.unhealthy_hosts.arn
  protocol  = "email"
  endpoint  = var.mailID

  depends_on = [
    aws_sns_topic.unhealthy_hosts
  ]
}