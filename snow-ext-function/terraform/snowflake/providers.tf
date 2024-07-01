# -------------------------------------------------------------------------
# Terraform configuration block to specify required providers
# -------------------------------------------------------------------------
terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.59.0"
    }
  }
}

# -------------------------------------------------------------------------
# Snowflake provider configuration
# -------------------------------------------------------------------------
provider "snowflake" {
  account  = var.snowflake_account
  region   = var.snowflake_region
  username = var.snowflake_user
  password = var.snowflake_password
  role     = var.snowflake_role
}