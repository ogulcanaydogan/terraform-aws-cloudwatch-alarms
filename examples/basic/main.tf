variable "instance_id" {
  description = "EC2 instance ID to monitor."
  type        = string
}

module "ec2_alarms" {
  source = "../.."

  name                   = "example"
  instance_id            = var.instance_id
  create_sns_topic       = true
  cpu_threshold          = 75
  cpu_period             = 300
  cpu_evaluation_periods = 2

  tags = {
    Environment = "example"
  }
}
