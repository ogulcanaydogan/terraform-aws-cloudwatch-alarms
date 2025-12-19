output "alarm_arns" {
  description = "Map of created CloudWatch alarm ARNs keyed by alarm type."
  value       = local.alarm_arns
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alarm notifications, if any."
  value       = local.sns_topic_arn
}
