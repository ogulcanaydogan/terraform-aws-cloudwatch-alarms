# terraform-aws-cloudwatch-alarms

A Terraform module that creates EC2-focused Amazon CloudWatch alarms with optional Amazon SNS notifications. The module is Terraform Registry-ready and ships with an example configuration.

## Features

- CPU utilization high alarm (enabled by default)
- EC2 status check failed alarm (enabled by default)
- Optional SNS topic creation, or reuse an existing topic ARN
- Alarm and OK actions automatically wired to the chosen SNS topic

## Prerequisites

- Terraform `>= 1.5`
- AWS provider `>= 5.0`
- An AWS account with permission to read EC2 metrics, create CloudWatch alarms, and optionally manage SNS topics

## Usage

### Create alarms and a new SNS topic

```hcl
module "ec2_alarms" {
  source = "github.com/your-org/terraform-aws-cloudwatch-alarms"

  name        = "web-server"
  instance_id = "i-0123456789abcdef0"

  create_sns_topic = true
  tags = {
    Environment = "production"
  }
}
```

### Reuse an existing SNS topic

```hcl
module "ec2_alarms" {
  source = "github.com/your-org/terraform-aws-cloudwatch-alarms"

  name           = "web-server"
  instance_id    = "i-0123456789abcdef0"
  sns_topic_arn  = "arn:aws:sns:us-east-1:123456789012:alerts"
  create_sns_topic = false
}
```

### Disable specific alarms

```hcl
module "ec2_alarms" {
  source = "github.com/your-org/terraform-aws-cloudwatch-alarms"

  name        = "web-server"
  instance_id = "i-0123456789abcdef0"

  enable_cpu_alarm           = false
  enable_status_check_alarm  = true
}
```

## Inputs

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `name` | Name prefix for alarms and the optional SNS topic. | `string` | n/a |
| `instance_id` | ID of the EC2 instance to monitor. | `string` | n/a |
| `tags` | Tags to apply to created resources. | `map(string)` | `{}` |
| `create_sns_topic` | Whether to create an SNS topic for notifications. | `bool` | `false` |
| `sns_topic_arn` | Existing SNS topic ARN to use when not creating one. | `string` | `null` |
| `cpu_threshold` | CPU utilization percentage threshold. | `number` | `80` |
| `cpu_period` | CPU metric period in seconds. | `number` | `300` |
| `cpu_evaluation_periods` | Number of CPU periods evaluated. | `number` | `2` |
| `enable_cpu_alarm` | Create the CPU utilization alarm. | `bool` | `true` |
| `enable_status_check_alarm` | Create the status check alarm. | `bool` | `true` |

## Outputs

| Name | Description |
| --- | --- |
| `alarm_arns` | Map of created alarm ARNs keyed by alarm type. |
| `sns_topic_arn` | ARN of the SNS topic used for notifications, if any. |

## Example

A basic example is available in [`examples/basic`](examples/basic), which demonstrates creating both alarms and an SNS topic.

## Notes

- When `create_sns_topic` is `false` and `sns_topic_arn` is `null`, alarms are created without notification actions.
- The status check alarm monitors `StatusCheckFailed` with a threshold of `1` over `2` periods of `60` seconds.
- The CPU utilization alarm averages `CPUUtilization` over the configured period and evaluation windows.
