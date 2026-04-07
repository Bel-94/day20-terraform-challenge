# MIGRATION FROM S3 → TERRAFORM CLOUD

# BEFORE (Day 6 pattern — S3 backend):
#   terraform {
#     backend "s3" {
#       bucket       = "belinda-terraform-state-30daychallenge"
#       key          = "day20/webserver-cluster/terraform.tfstate"
#       region       = "us-east-1"
#       use_lockfile = true
#       encrypt      = true
#     }
#   }

# AFTER (Terraform Cloud — today's pattern):
#   terraform {
#     cloud {
#       organization = "belinda-terraform-challenge"
#       workspaces {
#         name = "webserver-cluster-dev"
#       }
#     }
#   }

# MIGRATION STEPS:
# 1. Replace the backend "s3" block with cloud {} below
# 2. Run: terraform login (opens browser to authenticate with app.terraform.io)
# 3. Run: terraform init, Terraform asks: "Do you wish to proceed? (yes/no)"; Type yes — state migrates from S3 to Terraform Cloud
#
# WHAT CHANGES:
# - State file no longer in S3 — it lives in Terraform Cloud
# - Plans are recorded in the Terraform Cloud UI
# - AWS credentials move to workspace environment variables
# - Every run is logged with who triggered it

# WHAT STAYS THE SAME:
# - All your resource blocks are unchanged
# - Variables and outputs work exactly the same way
# - terraform plan and terraform apply work the same way
# -------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Terraform Cloud backend

  cloud {
    organization = "Bel_terra_acc"

    workspaces {
      name = "webserver-cluster-dev"
    }
  }
}

# Provider — credentials come from Terraform Cloud workspace environment variables, NOT from local environment variables or ~/.aws/credentials.

# In Terraform Cloud workspace settings, add:
#   AWS_ACCESS_KEY_ID     (Env var, mark Sensitive)
#   AWS_SECRET_ACCESS_KEY (Env var, mark Sensitive)
#   AWS_DEFAULT_REGION    (Env var, value: us-east-1)

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Day         = "Day 20"
      DeployedVia = "Terraform Cloud"
    }
  }
}
