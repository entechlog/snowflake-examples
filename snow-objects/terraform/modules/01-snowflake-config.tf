terraform {
  backend "remote" {
    organization = "entechlog"
    workspaces {
      prefix = "snowflake-"
    }
  }
}

locals {
  create_in_dev_map = {
    snowflake-dev = 1
    snowflake-stg = 0
    snowflake-prd = 0
  }

  create_in_prod_map = {
    snowflake-dev = 0
    snowflake-stg = 0
    snowflake-prd = 1
  }

  enable_in_dev_flag  = local.create_in_dev_map[terraform.workspace]
  enable_in_prod_flag = local.create_in_prod_map[terraform.workspace]
}

terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.70.1"
    }
  }
}

provider "snowflake" {
  account  = var.snowflake_account
  region   = var.snowflake_region
  username = var.snowflake_user
  password = var.snowflake_password
  role     = var.snowflake_role
}