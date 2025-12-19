output "alarm_arns" {
  description = "Alarm ARNs created by the example module."
  value       = module.ec2_alarms.alarm_arns
}

output "sns_topic_arn" {
  description = "SNS topic ARN used by the example module."
  value       = module.ec2_alarms.sns_topic_arn
}
