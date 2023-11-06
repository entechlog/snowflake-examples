//***************************************************************************//
// Create service roles using modules. 
// We will have one service role in each enviroment with different level of access
//***************************************************************************//

module "dbt_role" {
  source       = "../../../snow-objects/terraform/modules/roles"
  role_name    = "${upper(local.resource_prefix_with_env)}_DBT_ROLE"
  role_comment = "Snowflake role used by dbt in ${var.env_code}"

  roles = ["SYSADMIN"]
  users = [lower("${local.resource_prefix_with_env}_dbt_user")]

  depends_on = [module.all_service_accounts]
}

//***************************************************************************//
// Create user roles using modules. 
// We will have one user role for all enviroment with different level of access
//***************************************************************************//

module "da_role" {
  source       = "../../../snow-objects/terraform/modules/roles"
  count        = local.enable_in_dev_flag
  role_name    = "${upper(local.resource_prefix_without_env)}_DA_ROLE"
  role_comment = "Snowflake role used by Analyst"

  roles = ["SYSADMIN"]
  users = [lower("demo.analyst@example.com")]

  depends_on = [module.all_user_accounts]
}

module "de_role" {
  source       = "../../../snow-objects/terraform/modules/roles"
  count        = local.enable_in_dev_flag
  role_name    = "${upper(local.resource_prefix_without_env)}_DE_ROLE"
  role_comment = "Snowflake role used by Developers"

  roles = ["SYSADMIN"]
  users = [lower("demo.dev@example.com")]

  depends_on = [module.all_user_accounts]
}