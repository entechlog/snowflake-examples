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
    "demo.dev@example.com" : { "first_name" = "Demo", "last_name" = "Developer", "email" = "demo.dev@example.com", default_role = "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE" },
    "demo.analyst@example.com" : { "first_name" = "Demo", "last_name" = "Analyst", "email" = "demo.analyst@example.com", default_role = "${upper(local.resource_prefix_without_env)}_ANALYST_ROLE" }
  }
}

//***************************************************************************//
// Create service roles using modules. 
// We will have one service role in each enviroment with different level of access
//***************************************************************************//

module "dbt_role" {
  source       = "../../../snow-objects/terraform/modules/roles"
  role_name    = "${upper(local.resource_prefix_with_env)}_DBT_ROLE"
  role_comment = "Snowflake role used by dbt in ${var.required_env_code}"

  roles = ["SYSADMIN"]
  users = [lower("${local.resource_prefix_with_env}_dbt_user")]

  depends_on = [module.all_service_accounts]
}

//***************************************************************************//
// Create user roles using modules. 
// We will have one user role for all enviroment with different level of access
//***************************************************************************//

module "analyst_role" {
  source       = "../../../snow-objects/terraform/modules/roles"
  count        = local.enable_in_dev_flag
  role_name    = "${upper(local.resource_prefix_without_env)}_ANALYST_ROLE"
  role_comment = "Snowflake role used by Analyst"

  roles = ["SYSADMIN"]
  users = [lower("demo.analyst@example.com")]

  depends_on = [module.all_user_accounts]
}

module "developer_role" {
  source       = "../../../snow-objects/terraform/modules/roles"
  count        = local.enable_in_dev_flag
  role_name    = "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"
  role_comment = "Snowflake role used by Developers"

  roles = ["SYSADMIN"]
  users = [lower("demo.dev@example.com")]

  depends_on = [module.all_user_accounts]
}