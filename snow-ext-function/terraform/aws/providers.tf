# -------------------------------------------------------------------------
# Terraform configuration block to specify required providers
# -------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

# -------------------------------------------------------------------------
# AWS provider configuration
# -------------------------------------------------------------------------
provider "aws" {
  region  = var.aws_region
  profile = "terraform"

  # Default tags to be applied to all resources
  default_tags {
    tags = {
      "environment" = "${lower(var.env_code)}"
      "created_by"  = "terraform"
    }
  }
}
