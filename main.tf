locals {
  created_sns_topic_arn = try(aws_sns_topic.this[0].arn, null)
  sns_topic_arn         = var.create_sns_topic ? local.created_sns_topic_arn : var.sns_topic_arn
  alarm_actions         = local.sns_topic_arn != null ? [local.sns_topic_arn] : []
}

resource "aws_sns_topic" "this" {
  count = var.create_sns_topic ? 1 : 0

  name = "${var.name}-alarms"
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count = var.enable_cpu_alarm ? 1 : 0

  alarm_name          = "${var.name}-cpu-utilization-high"
  alarm_description   = "Average CPU utilization above ${var.cpu_threshold}% for ${var.cpu_evaluation_periods} period(s)."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_period
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  count = var.enable_status_check_alarm ? 1 : 0

  alarm_name          = "${var.name}-status-check-failed"
  alarm_description   = "Instance or system status check failed."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = var.tags
}

locals {
  alarm_arns = merge(
    { for alarm in aws_cloudwatch_metric_alarm.cpu_utilization_high : "cpu_utilization_high" => alarm.arn },
    { for alarm in aws_cloudwatch_metric_alarm.status_check_failed : "status_check_failed" => alarm.arn }
  )
}
