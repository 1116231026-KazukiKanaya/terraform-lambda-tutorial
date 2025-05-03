# ========================================
# Terraform configuration
# ========================================
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

# ========================================
# Provider
# ========================================
provider "aws" {
  profile = "terraform"
  region = "ap-northeast-3"
}

# ========================================
# Variable
# ========================================
variable "project" {
  type = string
}

variable "environment" {
  type = string
}