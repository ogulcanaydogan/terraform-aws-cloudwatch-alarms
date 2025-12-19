variable "name" {
  description = "A name prefix used for alarms and optional SNS topic."
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to monitor."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to created resources."
  type        = map(string)
  default     = {}
}

variable "create_sns_topic" {
  description = "Whether to create an SNS topic for alarm notifications."
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "Existing SNS topic ARN to use for notifications when not creating a topic."
  type        = string
  default     = null

  validation {
    condition     = var.create_sns_topic == false || var.sns_topic_arn == null
    error_message = "Set sns_topic_arn only when create_sns_topic is false."
  }
}

variable "cpu_threshold" {
  description = "The maximum average CPU utilization percentage before triggering the alarm."
  type        = number
  default     = 80
}

variable "cpu_period" {
  description = "Period in seconds over which CPU metrics are evaluated."
  type        = number
  default     = 300
}

variable "cpu_evaluation_periods" {
  description = "Number of CPU metric periods over which data is compared to the threshold."
  type        = number
  default     = 2
}

variable "enable_cpu_alarm" {
  description = "Whether to create the CPU utilization alarm."
  type        = bool
  default     = true
}

variable "enable_status_check_alarm" {
  description = "Whether to create the EC2 status check alarm."
  type        = bool
  default     = true
}
