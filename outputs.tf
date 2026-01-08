output "alarm_arns" {
  description = "Map of created CloudWatch alarm ARNs keyed by alarm type."
  value       = local.alarm_arns
}

output "alarm_names" {
  description = "Map of created CloudWatch alarm names keyed by alarm type."
  value       = local.alarm_names
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alarm notifications, if any."
  value       = local.sns_topic_arn
}

output "sns_topic_name" {
  description = "Name of the created SNS topic, if created."
  value       = var.create_sns_topic ? aws_sns_topic.this[0].name : null
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm, if created."
  value       = var.enable_cpu_alarm ? aws_cloudwatch_metric_alarm.cpu_utilization_high[0].arn : null
}

output "status_check_alarm_arn" {
  description = "ARN of the status check alarm, if created."
  value       = var.enable_status_check_alarm ? aws_cloudwatch_metric_alarm.status_check_failed[0].arn : null
}

output "memory_alarm_arn" {
  description = "ARN of the memory utilization alarm, if created."
  value       = var.enable_memory_alarm ? aws_cloudwatch_metric_alarm.memory_utilization_high[0].arn : null
}

output "disk_alarm_arn" {
  description = "ARN of the disk utilization alarm, if created."
  value       = var.enable_disk_alarm ? aws_cloudwatch_metric_alarm.disk_utilization_high[0].arn : null
}

output "network_in_alarm_arn" {
  description = "ARN of the network bytes in alarm, if created."
  value       = var.enable_network_in_alarm ? aws_cloudwatch_metric_alarm.network_in_high[0].arn : null
}

output "network_out_alarm_arn" {
  description = "ARN of the network bytes out alarm, if created."
  value       = var.enable_network_out_alarm ? aws_cloudwatch_metric_alarm.network_out_high[0].arn : null
}
