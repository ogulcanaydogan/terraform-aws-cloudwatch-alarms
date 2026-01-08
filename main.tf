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

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count = var.enable_cpu_alarm ? 1 : 0

  alarm_name          = "${var.name}-cpu-utilization-high"
  alarm_description   = "${var.cpu_statistic} CPU utilization above ${var.cpu_threshold}% for ${var.cpu_evaluation_periods} period(s)."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_evaluation_periods
  datapoints_to_alarm = var.cpu_datapoints_to_alarm
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_period
  statistic           = var.cpu_statistic
  threshold           = var.cpu_threshold
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = var.tags
}

# Status Check Failed Alarm
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  count = var.enable_status_check_alarm ? 1 : 0

  alarm_name          = "${var.name}-status-check-failed"
  alarm_description   = "Instance or system status check failed."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.status_check_evaluation_periods
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = var.status_check_period
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = var.tags
}

# Memory Utilization Alarm (requires CloudWatch Agent)
resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  count = var.enable_memory_alarm ? 1 : 0

  alarm_name          = "${var.name}-memory-utilization-high"
  alarm_description   = "Memory utilization above ${var.memory_threshold}% for ${var.memory_evaluation_periods} period(s)."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.memory_evaluation_periods
  metric_name         = var.memory_metric_name
  namespace           = var.cloudwatch_agent_namespace
  period              = var.memory_period
  statistic           = "Average"
  threshold           = var.memory_threshold
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = var.tags
}

# Disk Utilization Alarm (requires CloudWatch Agent)
resource "aws_cloudwatch_metric_alarm" "disk_utilization_high" {
  count = var.enable_disk_alarm ? 1 : 0

  alarm_name          = "${var.name}-disk-utilization-high"
  alarm_description   = "Disk utilization above ${var.disk_threshold}% on ${var.disk_path} for ${var.disk_evaluation_periods} period(s)."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.disk_evaluation_periods
  metric_name         = var.disk_metric_name
  namespace           = var.cloudwatch_agent_namespace
  period              = var.disk_period
  statistic           = "Average"
  threshold           = var.disk_threshold
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = merge(
    {
      InstanceId = var.instance_id
      path       = var.disk_path
    },
    var.disk_fstype != null ? { fstype = var.disk_fstype } : {}
  )

  tags = var.tags
}

# Network Bytes In Alarm
resource "aws_cloudwatch_metric_alarm" "network_in_high" {
  count = var.enable_network_in_alarm ? 1 : 0

  alarm_name          = "${var.name}-network-in-high"
  alarm_description   = "Network bytes in above ${var.network_in_threshold} bytes for ${var.network_evaluation_periods} period(s)."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.network_evaluation_periods
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = var.network_period
  statistic           = "Sum"
  threshold           = var.network_in_threshold
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = var.tags
}

# Network Bytes Out Alarm
resource "aws_cloudwatch_metric_alarm" "network_out_high" {
  count = var.enable_network_out_alarm ? 1 : 0

  alarm_name          = "${var.name}-network-out-high"
  alarm_description   = "Network bytes out above ${var.network_out_threshold} bytes for ${var.network_evaluation_periods} period(s)."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.network_evaluation_periods
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = var.network_period
  statistic           = "Sum"
  threshold           = var.network_out_threshold
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = var.tags
}

locals {
  alarm_arns = merge(
    var.enable_cpu_alarm ? { cpu_utilization_high = aws_cloudwatch_metric_alarm.cpu_utilization_high[0].arn } : {},
    var.enable_status_check_alarm ? { status_check_failed = aws_cloudwatch_metric_alarm.status_check_failed[0].arn } : {},
    var.enable_memory_alarm ? { memory_utilization_high = aws_cloudwatch_metric_alarm.memory_utilization_high[0].arn } : {},
    var.enable_disk_alarm ? { disk_utilization_high = aws_cloudwatch_metric_alarm.disk_utilization_high[0].arn } : {},
    var.enable_network_in_alarm ? { network_in_high = aws_cloudwatch_metric_alarm.network_in_high[0].arn } : {},
    var.enable_network_out_alarm ? { network_out_high = aws_cloudwatch_metric_alarm.network_out_high[0].arn } : {}
  )

  alarm_names = merge(
    var.enable_cpu_alarm ? { cpu_utilization_high = aws_cloudwatch_metric_alarm.cpu_utilization_high[0].alarm_name } : {},
    var.enable_status_check_alarm ? { status_check_failed = aws_cloudwatch_metric_alarm.status_check_failed[0].alarm_name } : {},
    var.enable_memory_alarm ? { memory_utilization_high = aws_cloudwatch_metric_alarm.memory_utilization_high[0].alarm_name } : {},
    var.enable_disk_alarm ? { disk_utilization_high = aws_cloudwatch_metric_alarm.disk_utilization_high[0].alarm_name } : {},
    var.enable_network_in_alarm ? { network_in_high = aws_cloudwatch_metric_alarm.network_in_high[0].alarm_name } : {},
    var.enable_network_out_alarm ? { network_out_high = aws_cloudwatch_metric_alarm.network_out_high[0].alarm_name } : {}
  )
}
