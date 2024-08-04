//***************************************************************************//
// Create service roles using modules. We will have one service role in each enviroment with different level of access
//***************************************************************************//

module "dbt_role" {
  source       = "./modules/roles"
  role_name    = "${upper(var.env_code)}_SVC_${upper(var.project_code)}_SNOW_DBT_ROLE"
  role_comment = "Snowflake role used by dbt in ${var.env_code}"

  roles = ["SYSADMIN"]
  users = [lower("${var.env_code}_svc_${lower(var.project_code)}_snow_dbt_user")]

  depends_on = [module.all_service_accounts]
}

module "atlan_role" {
  source       = "./modules/roles"
  role_name    = "${upper(var.env_code)}_SVC_${upper(var.project_code)}_SNOW_ATLAN_ROLE"
  role_comment = "Snowflake role used by Atlan in ${var.env_code}"

  roles = ["SYSADMIN"]
  users = [lower("${var.env_code}_svc_${lower(var.project_code)}_snow_atlan_user")]

  depends_on = [module.all_service_accounts]
}

module "kafka_role" {
  source       = "./modules/roles"
  role_name    = "${upper(var.env_code)}_SVC_${upper(var.project_code)}_SNOW_KAFKA_ROLE"
  role_comment = "Snowflake role used by Kafka in ${var.env_code}"

  roles = ["SYSADMIN"]
  users = [lower("${var.env_code}_svc_${lower(var.project_code)}_snow_kafka_user")]

  depends_on = [module.all_service_accounts]
}

//***************************************************************************//
// Create user roles using modules. We will have one user role for all enviroment with different level of access
//***************************************************************************//

module "da_role" {
  source       = "./modules/roles"
  count        = local.enable_in_dev_flag
  role_name    = "${upper(var.project_code)}_DA_ROLE"
  role_comment = "Snowflake role used by Analyst"

  roles = ["SYSADMIN"]
  users = [lower("admin@entechlog.com")]

  depends_on = [module.all_user_accounts]
}

module "de_role" {
  source       = "./modules/roles"
  count        = local.enable_in_dev_flag
  role_name    = "${upper(var.project_code)}_DE_ROLE"
  role_comment = "Snowflake role used by Developers"

  roles = ["SYSADMIN"]
  users = [lower("admin@entechlog.com")]

  depends_on = [module.all_user_accounts]
}