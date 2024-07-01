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
