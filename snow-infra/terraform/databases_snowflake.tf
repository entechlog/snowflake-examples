resource "snowflake_grant_privileges_to_account_role" "snowflake_imported_privileges_to_dbt" {
  account_role_name = module.dbt_role.role.name
  privileges        = ["IMPORTED PRIVILEGES"]
  
  on_account_object {
    object_type = "DATABASE"
    object_name = "SNOWFLAKE"
  }
  
  with_grant_option = false
}