# These variables are configured in two places:
# - Sensitive ones (AWS credentials) in Terraform Cloud
#   workspace as Environment Variables marked Sensitive
# - Non-sensitive ones (cluster_name, instance_type) in Terraform Cloud workspace as Terraform Variables

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Base name for all resources"
  type        = string
  default     = "belinda-day20"
}

variable "instance_type" {
  description = "EC2 instance type — must be t2 or t3 family"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "Instance type must be t2 or t3 family."
  }
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 4
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "app_version" {
  description = "Version label for the deployed application — used in tags and HTML response"
  type        = string
  default     = "v3"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI for us-east-1"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "cpu_alarm_threshold" {
  description = "CPU utilisation percentage that triggers the CloudWatch alarm"
  type        = number
  default     = 80
}

variable "project_name" {
  description = "Project name tag applied to all resources"
  type        = string
  default     = "30-Day Terraform Challenge"
}

variable "team_name" {
  description = "Owner tag applied to all resources"
  type        = string
  default     = "Belinda Ntinyari"
}
