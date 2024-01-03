terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.optional_aws_region
  profile = "terraform"

  default_tags {
    tags = {
      "environment" = "${lower(var.required_env_code)}"
      "created_by"  = "terraform"
    }
  }
}