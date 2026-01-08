# terraform-aws-cloudwatch-alarms

A Terraform module that creates EC2-focused Amazon CloudWatch alarms with optional Amazon SNS notifications. The module supports CPU, memory, disk, network, and status check monitoring.

## Features

- **CPU utilization alarm** - Monitor high CPU usage (enabled by default)
- **Status check alarm** - Monitor EC2 instance and system health (enabled by default)
- **Memory utilization alarm** - Monitor memory usage (requires CloudWatch Agent)
- **Disk utilization alarm** - Monitor disk usage (requires CloudWatch Agent)
- **Network alarms** - Monitor network bytes in/out
- **SNS integration** - Create new or use existing SNS topic for notifications
- **Configurable thresholds** - All alarm parameters are customizable
- **Missing data handling** - Configure how alarms treat missing data points
- **Input validation** - Comprehensive validation for all variables

## Prerequisites

- Terraform `>= 1.5`
- AWS provider `>= 5.0`
- An AWS account with permission to read EC2 metrics, create CloudWatch alarms, and optionally manage SNS topics
- **For memory/disk alarms**: CloudWatch Agent installed and configured on the EC2 instance

## Usage

### Basic - CPU and Status Check Alarms

```hcl
module "ec2_alarms" {
  source = "github.com/ogulcanaydogan/terraform-aws-cloudwatch-alarms"

  name             = "web-server"
  instance_id      = "i-0123456789abcdef0"
  create_sns_topic = true

  tags = {
    Environment = "production"
  }
}
```

### With Existing SNS Topic

```hcl
module "ec2_alarms" {
  source = "github.com/ogulcanaydogan/terraform-aws-cloudwatch-alarms"

  name          = "web-server"
  instance_id   = "i-0123456789abcdef0"
  sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:alerts"

  tags = {
    Environment = "production"
  }
}
```

### Full Monitoring (CPU, Memory, Disk, Network)

```hcl
module "ec2_alarms" {
  source = "github.com/ogulcanaydogan/terraform-aws-cloudwatch-alarms"

  name             = "web-server"
  instance_id      = "i-0123456789abcdef0"
  create_sns_topic = true

  # CPU alarm settings
  cpu_threshold          = 80
  cpu_period             = 300
  cpu_evaluation_periods = 2

  # Memory alarm (requires CloudWatch Agent)
  enable_memory_alarm = true
  memory_threshold    = 85

  # Disk alarm (requires CloudWatch Agent)
  enable_disk_alarm = true
  disk_threshold    = 80
  disk_path         = "/"

  # Network alarms
  enable_network_in_alarm  = true
  enable_network_out_alarm = true
  network_in_threshold     = 1000000000  # 1 GB
  network_out_threshold    = 1000000000  # 1 GB

  # How to handle missing data
  treat_missing_data = "notBreaching"

  tags = {
    Environment = "production"
  }
}
```

### Custom Thresholds

```hcl
module "ec2_alarms" {
  source = "github.com/ogulcanaydogan/terraform-aws-cloudwatch-alarms"

  name             = "high-cpu-workload"
  instance_id      = "i-0123456789abcdef0"
  create_sns_topic = true

  # Higher CPU threshold for compute-intensive workloads
  cpu_threshold          = 95
  cpu_period             = 60
  cpu_evaluation_periods = 5
  cpu_datapoints_to_alarm = 3  # 3 of 5 datapoints must breach
  cpu_statistic          = "Maximum"

  # Faster status check response
  status_check_period             = 60
  status_check_evaluation_periods = 1

  tags = {
    Environment = "production"
    Workload    = "compute"
  }
}
```

## Inputs

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `name` | Name prefix for alarms and the optional SNS topic | `string` |
| `instance_id` | ID of the EC2 instance to monitor | `string` |

### SNS Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_sns_topic` | Whether to create an SNS topic for notifications | `bool` | `false` |
| `sns_topic_arn` | Existing SNS topic ARN to use when not creating one | `string` | `null` |

### General Settings

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `tags` | Tags to apply to created resources | `map(string)` | `{}` |
| `treat_missing_data` | How to treat missing data (missing, ignore, breaching, notBreaching) | `string` | `"missing"` |
| `cloudwatch_agent_namespace` | CloudWatch Agent namespace for custom metrics | `string` | `"CWAgent"` |

### CPU Alarm Settings

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_cpu_alarm` | Create the CPU utilization alarm | `bool` | `true` |
| `cpu_threshold` | CPU utilization percentage threshold (1-100) | `number` | `80` |
| `cpu_period` | CPU metric period in seconds | `number` | `300` |
| `cpu_evaluation_periods` | Number of CPU periods evaluated | `number` | `2` |
| `cpu_datapoints_to_alarm` | Datapoints that must breach to trigger alarm | `number` | `null` |
| `cpu_statistic` | Statistic to use (Average, Maximum, Minimum, etc.) | `string` | `"Average"` |

### Status Check Alarm Settings

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_status_check_alarm` | Create the status check alarm | `bool` | `true` |
| `status_check_period` | Status check metric period in seconds | `number` | `60` |
| `status_check_evaluation_periods` | Number of status check periods evaluated | `number` | `2` |

### Memory Alarm Settings (Requires CloudWatch Agent)

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_memory_alarm` | Create the memory utilization alarm | `bool` | `false` |
| `memory_threshold` | Memory utilization percentage threshold (1-100) | `number` | `80` |
| `memory_period` | Memory metric period in seconds | `number` | `300` |
| `memory_evaluation_periods` | Number of memory periods evaluated | `number` | `2` |
| `memory_metric_name` | CloudWatch Agent metric name for memory | `string` | `"mem_used_percent"` |

### Disk Alarm Settings (Requires CloudWatch Agent)

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_disk_alarm` | Create the disk utilization alarm | `bool` | `false` |
| `disk_threshold` | Disk utilization percentage threshold (1-100) | `number` | `80` |
| `disk_period` | Disk metric period in seconds | `number` | `300` |
| `disk_evaluation_periods` | Number of disk periods evaluated | `number` | `2` |
| `disk_path` | Disk mount path to monitor (e.g., /, /data) | `string` | `"/"` |
| `disk_metric_name` | CloudWatch Agent metric name for disk | `string` | `"disk_used_percent"` |
| `disk_fstype` | Filesystem type filter (e.g., ext4, xfs) | `string` | `null` |

### Network Alarm Settings

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_network_in_alarm` | Create the network bytes in alarm | `bool` | `false` |
| `enable_network_out_alarm` | Create the network bytes out alarm | `bool` | `false` |
| `network_in_threshold` | Network bytes in threshold | `number` | `1000000000` |
| `network_out_threshold` | Network bytes out threshold | `number` | `1000000000` |
| `network_period` | Network metric period in seconds | `number` | `300` |
| `network_evaluation_periods` | Number of network periods evaluated | `number` | `2` |

## Outputs

| Name | Description |
|------|-------------|
| `alarm_arns` | Map of created alarm ARNs keyed by alarm type |
| `alarm_names` | Map of created alarm names keyed by alarm type |
| `sns_topic_arn` | ARN of the SNS topic used for notifications |
| `sns_topic_name` | Name of the created SNS topic, if created |
| `cpu_alarm_arn` | ARN of the CPU utilization alarm |
| `status_check_alarm_arn` | ARN of the status check alarm |
| `memory_alarm_arn` | ARN of the memory utilization alarm |
| `disk_alarm_arn` | ARN of the disk utilization alarm |
| `network_in_alarm_arn` | ARN of the network bytes in alarm |
| `network_out_alarm_arn` | ARN of the network bytes out alarm |

## CloudWatch Agent Setup

Memory and disk alarms require the CloudWatch Agent to be installed on your EC2 instance. Here's a minimal agent configuration:

```json
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"]
      },
      "disk": {
        "measurement": ["disk_used_percent"],
        "resources": ["/"],
        "ignore_file_system_types": ["sysfs", "devtmpfs"]
      }
    },
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    }
  }
}
```

See [Installing the CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance.html) for detailed instructions.

## Example

A basic example is available in [`examples/basic`](examples/basic).

## Notes

- When `create_sns_topic` is `false` and `sns_topic_arn` is `null`, alarms are created without notification actions
- Memory and disk alarms use the `CWAgent` namespace by default (configurable via `cloudwatch_agent_namespace`)
- Valid period values are: 10, 30, 60, 300, 600, 900, 1800, 3600 seconds
- The `treat_missing_data` option helps prevent false alarms during instance stops or metric gaps

## Recommended Thresholds

| Alarm Type | Conservative | Moderate | Aggressive |
|------------|--------------|----------|------------|
| CPU | 90% | 80% | 70% |
| Memory | 90% | 85% | 80% |
| Disk | 90% | 80% | 70% |
| Network | Depends on instance type and workload |

Choose thresholds based on your application's characteristics and tolerance for alerts.
