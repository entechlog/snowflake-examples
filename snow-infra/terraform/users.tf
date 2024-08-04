//***************************************************************************//
// Create Snowflake service accounts using modules. We will have one service account in each enviroment with different roles and each with different level of access
//***************************************************************************//

module "all_service_accounts" {
  source = "./modules/user"
  user_map = {
    "${lower(var.env_code)}_svc_${lower(var.project_code)}_snow_dbt_user" : { "first_name" = "dbt", "last_name" = "User" },
    "${lower(var.env_code)}_svc_${lower(var.project_code)}_snow_atlan_user" : { "first_name" = "Atlan", "last_name" = "User" },
    "${lower(var.env_code)}_svc_${lower(var.project_code)}_snow_kafka_user" : { "first_name" = "Kafka", "last_name" = "User", default_role = "${upper(var.env_code)}_SVC_${upper(var.project_code)}_SNOW_KAFKA_ROLE" }
  }
}

//***************************************************************************//
// Create Snowflake user accounts using modules. We will have only one user account for all enviroment
//***************************************************************************//

module "all_user_accounts" {
  source = "./modules/user"
  count  = local.enable_in_dev_flag
  user_map = {
    "admin@entechlog.com" : { "first_name" = "Siva", "last_name" = "Nadesan", "email" = "admin@entechlog.com" }
  }
}