# AWS Provider configuration
provider "aws" {
  region = var.aws_region
}

# Random provider for unique resource naming
provider "random" {}

# Terraform settings
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  
  required_version = ">= 1.0"
}
