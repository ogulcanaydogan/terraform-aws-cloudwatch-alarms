terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region for the example configuration."
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}
