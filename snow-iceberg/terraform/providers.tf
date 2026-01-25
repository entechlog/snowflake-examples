terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.11.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_username
  password          = var.snowflake_password
  role              = var.snowflake_role
  warehouse         = var.snowflake_warehouse
  authenticator     = "Snowflake"

  disable_telemetry = true
  preview_features_enabled = ["snowflake_table_resource",
    "snowflake_external_volume_resource",
    "snowflake_stage_resource",
    "snowflake_storage_integration_resource",
  "snowflake_file_format_resource"]
}