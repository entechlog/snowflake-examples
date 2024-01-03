//***************************************************************************//
// Create Snowflake service accounts using modules. 
// We will have one service account in each enviroment with different roles and each with different level of access
//***************************************************************************//

module "all_service_accounts" {
  source = "../../../snow-objects/terraform/modules/user"
  user_map = {
  "${local.resource_prefix_with_env}_dbt_user" : { "first_name" = "dbt", "last_name" = "User", default_role = "${upper(local.resource_prefix_with_env)}_DBT_ROLE" } }
}

//***************************************************************************//
// Create Snowflake user accounts using modules. 
// We will have only one user account for all enviroment
//***************************************************************************//

module "all_user_accounts" {
  source = "../../../snow-objects/terraform/modules/user"
  count  = local.enable_in_dev_flag
  user_map = {
    "demo.dev@example.com" : { "first_name" = "Demo", "last_name" = "Developer", "email" = "demo.dev@example.com", default_role = "${upper(local.resource_prefix_without_env)}_DE_ROLE" },
    "demo.analyst@example.com" : { "first_name" = "Demo", "last_name" = "Analyst", "email" = "demo.analyst@example.com", default_role = "${upper(local.resource_prefix_without_env)}_DA_ROLE" }
  }
}
