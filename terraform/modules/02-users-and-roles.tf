//***************************************************************************//
// Create Snowflake service accounts using modules. We will have one service account in each enviroment with different roles and each with different level of access
//***************************************************************************//

module "all_service_accounts" {
  source = "./user"
  user_map = {
    "${lower(var.env_code)}_entechlog_dbt_user" : { "first_name" = "dbt", "last_name" = "User" },
    "${lower(var.env_code)}_entechlog_atlan_user" : { "first_name" = "Atlan", "last_name" = "User" },
    "${lower(var.env_code)}_entechlog_kafka_user" : { "first_name" = "Kafka", "last_name" = "User" }
  }
}

//***************************************************************************//
// Create Snowflake user accounts using modules. We will have only one user account for all enviroment
//***************************************************************************//

module "all_user_accounts" {
  source = "./user"
  count  = local.enable_in_dev_flag
  user_map = {
    "admin@entechlog.com" : { "first_name" = "Siva", "last_name" = "Nadesan", "email" = "admin@entechlog.com" }
  }
}

//***************************************************************************//
// Create service roles using modules. We will have one service role in each enviroment with different level of access
//***************************************************************************//

module "entechlog_dbt_role" {
  source       = "./roles"
  role_name    = "${upper(var.env_code)}_ENTECHLOG_DBT_ROLE"
  role_comment = "Snowflake role used by dbt in ${var.env_code}"

  roles = ["SYSADMIN"]
  users = [lower("${var.env_code}_entechlog_dbt_user")]

  depends_on = [module.all_service_accounts]
}

module "entechlog_atlan_role" {
  source       = "./roles"
  role_name    = "${upper(var.env_code)}_ENTECHLOG_ATLAN_ROLE"
  role_comment = "Snowflake role used by Atlan in ${var.env_code}"

  roles = ["SYSADMIN"]
  users = [lower("${var.env_code}_entechlog_atlan_user")]

  depends_on = [module.all_service_accounts]
}

module "entechlog_kafka_role" {
  source       = "./roles"
  role_name    = "${upper(var.env_code)}_ENTECHLOG_KAFKA_ROLE"
  role_comment = "Snowflake role used by Kafka in ${var.env_code}"

  roles = ["SYSADMIN"]
  users = [lower("${var.env_code}_entechlog_kafka_user")]

  depends_on = [module.all_service_accounts]
}

//***************************************************************************//
// Create user roles using modules. We will have one user role for all enviroment with different level of access
//***************************************************************************//

module "entechlog_analyst_role" {
  source       = "./roles"
  count        = local.enable_in_dev_flag
  role_name    = "ENTECHLOG_ANALYST_ROLE"
  role_comment = "Snowflake role used by Analyst"

  roles = ["SYSADMIN"]
  users = [lower("admin@entechlog.com")]

  depends_on = [module.all_user_accounts]
}

module "entechlog_developer_role" {
  source       = "./roles"
  count        = local.enable_in_dev_flag
  role_name    = "ENTECHLOG_DEVELOPER_ROLE"
  role_comment = "Snowflake role used by Developers"

  roles = ["SYSADMIN"]
  users = [lower("admin@entechlog.com")]

  depends_on = [module.all_user_accounts]
}

// Output block starts here

output "all_service_accounts" {
  value     = module.all_service_accounts
  sensitive = true
}

output "all_user_accounts" {
  value     = module.all_user_accounts
  sensitive = true
}