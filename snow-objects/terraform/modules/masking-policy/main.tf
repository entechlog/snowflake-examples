terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.35.0"
    }
  }
}

resource "snowflake_masking_policy" "masking_policy" {
  name               = var.masking_policy_name
  database           = var.masking_policy_database
  schema             = var.masking_policy_schema
  value_data_type    = var.masking_value_data_type
  masking_expression = var.masking_expression
  return_data_type   = var.masking_return_data_type
}

resource "snowflake_masking_policy_grant" "masking_policy_grant" {
  for_each            = var.masking_grants
  database_name       = var.masking_policy_database
  schema_name         = var.masking_policy_schema
  masking_policy_name = snowflake_masking_policy.masking_policy.name
  privilege           = each.key
  roles               = each.value
}

output "masking_policy" {
  value = snowflake_masking_policy.masking_policy
}
