terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.47.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "terraform"
}

provider "snowflake" {
  account  = var.snowflake_account
  region   = var.snowflake_region
  username = var.snowflake_user
  password = var.snowflake_password
  role     = var.snowflake_role
}
