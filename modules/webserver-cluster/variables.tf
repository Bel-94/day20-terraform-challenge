variable "cluster_name" {
  description = "Base name for all cluster resources. Required — no default."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type. Must be t2 or t3 family."
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "Instance type must be t2 or t3 family."
  }
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "environment" {
  description = "Deployment environment: dev, staging, or production"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "app_version" {
  description = "Application version label — appears in HTML response and instance tags"
  type        = string
  default     = "v1"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID for us-east-1"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "project_name" {
  description = "Project name tag"
  type        = string
  default     = "30-Day Terraform Challenge"
}

variable "team_name" {
  description = "Owner tag"
  type        = string
  default     = "Belinda Ntinyari"
}
