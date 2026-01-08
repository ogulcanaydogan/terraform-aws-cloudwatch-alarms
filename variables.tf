variable "name" {
  description = "A name prefix used for alarms and optional SNS topic."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 255
    error_message = "name must be between 1 and 255 characters."
  }
}

variable "instance_id" {
  description = "ID of the EC2 instance to monitor."
  type        = string

  validation {
    condition     = can(regex("^i-[a-f0-9]{8,17}$", var.instance_id))
    error_message = "instance_id must be a valid EC2 instance ID (e.g., i-1234567890abcdef0)."
  }
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
    condition     = var.sns_topic_arn == null || can(regex("^arn:aws[a-zA-Z-]*:sns:[a-z0-9-]+:\\d{12}:.+$", var.sns_topic_arn))
    error_message = "sns_topic_arn must be a valid SNS topic ARN."
  }
}

variable "treat_missing_data" {
  description = "How to treat missing data points. Options: missing, ignore, breaching, notBreaching."
  type        = string
  default     = "missing"

  validation {
    condition     = contains(["missing", "ignore", "breaching", "notBreaching"], var.treat_missing_data)
    error_message = "treat_missing_data must be one of: missing, ignore, breaching, notBreaching."
  }
}

# CPU Alarm Variables
variable "enable_cpu_alarm" {
  description = "Whether to create the CPU utilization alarm."
  type        = bool
  default     = true
}

variable "cpu_threshold" {
  description = "The maximum average CPU utilization percentage before triggering the alarm."
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_threshold > 0 && var.cpu_threshold <= 100
    error_message = "cpu_threshold must be between 1 and 100."
  }
}

variable "cpu_period" {
  description = "Period in seconds over which CPU metrics are evaluated."
  type        = number
  default     = 300

  validation {
    condition     = contains([10, 30, 60, 300, 600, 900, 1800, 3600], var.cpu_period)
    error_message = "cpu_period must be one of: 10, 30, 60, 300, 600, 900, 1800, 3600 seconds."
  }
}

variable "cpu_evaluation_periods" {
  description = "Number of CPU metric periods over which data is compared to the threshold."
  type        = number
  default     = 2

  validation {
    condition     = var.cpu_evaluation_periods >= 1 && var.cpu_evaluation_periods <= 100
    error_message = "cpu_evaluation_periods must be between 1 and 100."
  }
}

variable "cpu_datapoints_to_alarm" {
  description = "Number of datapoints that must be breaching to trigger the CPU alarm. Must be <= cpu_evaluation_periods."
  type        = number
  default     = null
}

variable "cpu_statistic" {
  description = "Statistic to use for CPU alarm. Options: Average, Maximum, Minimum, SampleCount, Sum."
  type        = string
  default     = "Average"

  validation {
    condition     = contains(["Average", "Maximum", "Minimum", "SampleCount", "Sum"], var.cpu_statistic)
    error_message = "cpu_statistic must be one of: Average, Maximum, Minimum, SampleCount, Sum."
  }
}

# Status Check Alarm Variables
variable "enable_status_check_alarm" {
  description = "Whether to create the EC2 status check alarm."
  type        = bool
  default     = true
}

variable "status_check_period" {
  description = "Period in seconds over which status check metrics are evaluated."
  type        = number
  default     = 60

  validation {
    condition     = contains([10, 30, 60, 300, 600, 900, 1800, 3600], var.status_check_period)
    error_message = "status_check_period must be one of: 10, 30, 60, 300, 600, 900, 1800, 3600 seconds."
  }
}

variable "status_check_evaluation_periods" {
  description = "Number of status check periods over which data is compared to the threshold."
  type        = number
  default     = 2

  validation {
    condition     = var.status_check_evaluation_periods >= 1 && var.status_check_evaluation_periods <= 100
    error_message = "status_check_evaluation_periods must be between 1 and 100."
  }
}

# Memory Alarm Variables (requires CloudWatch Agent)
variable "enable_memory_alarm" {
  description = "Whether to create the memory utilization alarm. Requires CloudWatch Agent on the instance."
  type        = bool
  default     = false
}

variable "memory_threshold" {
  description = "The maximum memory utilization percentage before triggering the alarm."
  type        = number
  default     = 80

  validation {
    condition     = var.memory_threshold > 0 && var.memory_threshold <= 100
    error_message = "memory_threshold must be between 1 and 100."
  }
}

variable "memory_period" {
  description = "Period in seconds over which memory metrics are evaluated."
  type        = number
  default     = 300

  validation {
    condition     = contains([10, 30, 60, 300, 600, 900, 1800, 3600], var.memory_period)
    error_message = "memory_period must be one of: 10, 30, 60, 300, 600, 900, 1800, 3600 seconds."
  }
}

variable "memory_evaluation_periods" {
  description = "Number of memory metric periods over which data is compared to the threshold."
  type        = number
  default     = 2

  validation {
    condition     = var.memory_evaluation_periods >= 1 && var.memory_evaluation_periods <= 100
    error_message = "memory_evaluation_periods must be between 1 and 100."
  }
}

variable "memory_metric_name" {
  description = "CloudWatch Agent metric name for memory. Common values: mem_used_percent (Linux), Memory % Committed Bytes In Use (Windows)."
  type        = string
  default     = "mem_used_percent"
}

# Disk Alarm Variables (requires CloudWatch Agent)
variable "enable_disk_alarm" {
  description = "Whether to create the disk utilization alarm. Requires CloudWatch Agent on the instance."
  type        = bool
  default     = false
}

variable "disk_threshold" {
  description = "The maximum disk utilization percentage before triggering the alarm."
  type        = number
  default     = 80

  validation {
    condition     = var.disk_threshold > 0 && var.disk_threshold <= 100
    error_message = "disk_threshold must be between 1 and 100."
  }
}

variable "disk_period" {
  description = "Period in seconds over which disk metrics are evaluated."
  type        = number
  default     = 300

  validation {
    condition     = contains([10, 30, 60, 300, 600, 900, 1800, 3600], var.disk_period)
    error_message = "disk_period must be one of: 10, 30, 60, 300, 600, 900, 1800, 3600 seconds."
  }
}

variable "disk_evaluation_periods" {
  description = "Number of disk metric periods over which data is compared to the threshold."
  type        = number
  default     = 2

  validation {
    condition     = var.disk_evaluation_periods >= 1 && var.disk_evaluation_periods <= 100
    error_message = "disk_evaluation_periods must be between 1 and 100."
  }
}

variable "disk_path" {
  description = "The disk mount path to monitor (e.g., / for Linux root, C: for Windows)."
  type        = string
  default     = "/"
}

variable "disk_metric_name" {
  description = "CloudWatch Agent metric name for disk. Common values: disk_used_percent (Linux), LogicalDisk % Free Space (Windows)."
  type        = string
  default     = "disk_used_percent"
}

variable "disk_fstype" {
  description = "Filesystem type for disk monitoring (e.g., ext4, xfs). Set to null to not filter by fstype."
  type        = string
  default     = null
}

# Network Alarm Variables
variable "enable_network_in_alarm" {
  description = "Whether to create the network bytes in alarm."
  type        = bool
  default     = false
}

variable "network_in_threshold" {
  description = "The network bytes in threshold (in bytes) before triggering the alarm."
  type        = number
  default     = 1000000000

  validation {
    condition     = var.network_in_threshold > 0
    error_message = "network_in_threshold must be greater than 0."
  }
}

variable "enable_network_out_alarm" {
  description = "Whether to create the network bytes out alarm."
  type        = bool
  default     = false
}

variable "network_out_threshold" {
  description = "The network bytes out threshold (in bytes) before triggering the alarm."
  type        = number
  default     = 1000000000

  validation {
    condition     = var.network_out_threshold > 0
    error_message = "network_out_threshold must be greater than 0."
  }
}

variable "network_period" {
  description = "Period in seconds over which network metrics are evaluated."
  type        = number
  default     = 300

  validation {
    condition     = contains([10, 30, 60, 300, 600, 900, 1800, 3600], var.network_period)
    error_message = "network_period must be one of: 10, 30, 60, 300, 600, 900, 1800, 3600 seconds."
  }
}

variable "network_evaluation_periods" {
  description = "Number of network metric periods over which data is compared to the threshold."
  type        = number
  default     = 2

  validation {
    condition     = var.network_evaluation_periods >= 1 && var.network_evaluation_periods <= 100
    error_message = "network_evaluation_periods must be between 1 and 100."
  }
}

variable "cloudwatch_agent_namespace" {
  description = "CloudWatch Agent namespace for custom metrics (memory, disk)."
  type        = string
  default     = "CWAgent"
}
